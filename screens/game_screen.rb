# require 'rubygems'
# require 'gosu'
require 'screens/title_screen'
require 'game_constants'
require 'bounds'

class GameScreen
  include GameConstants
  include Bounds
  
  def initialize(game_window, game_controller, asset_manager, width, height)
    @game_window = game_window
    @game_controller = game_controller
    @asset_manager = asset_manager
    
    # TODO: Confirm if we can get these direct from the game_window
    @width = width
    @height = height
    
    @player = Player.new(@asset_manager.player_image, PlayerBoundingSphereRadius)
    
    @bullet_manager = BulletManager.new(NumberOfBullets, @asset_manager.bullet_image, BulletBoundingSphereRadius)
    @bullet_fired = false
    
    @asteroid_manager = AsteroidManager.new(
            MaxAsteroidsInPool,
            @asset_manager.large_asteroid_image,
            @asset_manager.medium_asteroid_image,
            @asset_manager.small_asteroid_image
    )
  
    @score = 0
    @lives = 3
    @next_bullet_delay = 0

    @asteroid_manager.start_new_wave
  end
  
  def update
    read_player_input if @player.active?

    @player.update
    @bullet_manager.update
    @asteroid_manager.update
    
    test_player_asteroid_collisions if @player.active?
    
    @bullet_manager.bullets.each do |bullet|
      test_bullet_asteroid_collision(bullet)
    end
  end
  
  def draw
    @asset_manager.background_image.draw(0, 0, ZOrder::Background)
    @bullet_manager.draw
    @asteroid_manager.draw
    @player.draw
    
    @asset_manager.font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @asset_manager.font.draw("Lives: #{@lives}", 10, 30, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
  
  private
  def read_player_input
    if @game_controller.turn_left_down?
      @player.turn_left
    elsif @game_controller.turn_right_down?
      @player.turn_right
    end

    @game_controller.thrust_forward_down? ? @player.fire_thrust : @player.slow_down
    @player.hyperspace if @game_controller.hyperspace_down?
    
    if @game_controller.fire_weapon_down? and @next_bullet_delay == 0 and !@player.in_hyperspace then
      @bullet_manager.fire_bullet(@player.location_x, @player.location_y, @player.velocity_x, @player.velocity_y, @player.angle)
      @next_bullet_delay = BulletFireDelay
    end
    @next_bullet_delay -= 1 if @next_bullet_delay > 0
  end

  def test_bullet_asteroid_collision(bullet)
    collision = @asteroid_manager.test_for_collision(bullet, true)
    
    if collision then
      @bullet_manager.remove_bullet(bullet)
      @score = @score + AsteroidScore
      
      @asteroid_manager.start_new_wave if !@asteroid_manager.has_active_asteroids?    
    end
  end
  
  def test_player_asteroid_collisions
    collision = @asteroid_manager.test_for_collision(@player, false)
    
    if collision then
      @player.kill_player
      @lives = @lives - 1
      @game_window.active_screen = TitleScreen.new(@game_window, @game_controller, @asset_manager, @width, @height) if @lives < 0
    end
  end
end