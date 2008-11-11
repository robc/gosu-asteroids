require 'rubygems'
require 'gosu'
require 'player'
require 'game_constants'
require 'bounds'
require 'bullet_manager'
require 'asteroid_manager'
require 'lib/game_controller'

module ZOrder
  Background, Asteroids, Player, UI = *0..3
end

class AsteroidsGameWindow < Gosu::Window
  include GameConstants, Bounds
  
  def initialize
    super(ScreenWidth, ScreenHeight, false)
    self.caption = "Asteroids Game"
    
    @background_image = Gosu::Image.new(self, "media/IngameBackground.png", true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    
    @player_image = Gosu::Image.new(self, "media/Spaceship.png", true)
    @player = Player.new(@player_image, PlayerBoundingSphereRadius)
    
    @bullet_image = Gosu::Image.new(self, "media/Bullet.png", true)
    @bullet_manager = BulletManager.new(NumberOfBullets, @bullet_image, BulletBoundingSphereRadius)
    @bullet_fired = false
    
    @large_asteroid_image = Gosu::Image.new(self, "media/AsteroidLarge.png", true)
    @medium_asteroid_image = Gosu::Image.new(self, "media/AsteroidMedium.png", true)
    @small_asteroid_image = Gosu::Image.new(self, "media/AsteroidSmall.png", true)
    @asteroid_manager = AsteroidManager.new(
            MaxAsteroidsInPool,
            @large_asteroid_image,
            @medium_asteroid_image,
            @small_asteroid_image
    )
  
    @score = 0
    @lives = 3
    @next_bullet_delay = 0
    
    @game_over_flag = true
    
    @game_controller = GameController.new(self)
    @game_controller.key_turn_left = Gosu::KbLeft
    @game_controller.key_turn_right = Gosu::KbRight
    @game_controller.key_thrust_forward = Gosu::KbUp
    @game_controller.key_fire_weapon = Gosu::KbSpace
    @game_controller.key_hyperspace = Gosu::KbLeftShift
    
    @game_controller.gamepad_turn_left = Gosu::GpLeft
    @game_controller.gamepad_turn_right = Gosu::GpRight
    @game_controller.gamepad_thrust_forward = Gosu::GpUp
    @game_controller.gamepad_fire_weapon = Gosu::GpButton0
    @game_controller.gamepad_hyperspace = Gosu::GpButton1
  end

  def update
    @game_over_flag ? update_title_screen : update_ingame
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    
    if !@game_over_flag
      @bullet_manager.draw
      @asteroid_manager.draw
      @player.draw
    end
    
    # Params: String, x position, y position, layer, scale, colour
    @font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Lives: #{@lives}", 10, 30, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Hyperspace: #{@player.respawn_time}", 10, 50, ZOrder::UI, 1.0, 1.0, 0xffffff00) if @player.in_hyperspace
    @font.draw("Respawn: #{@player.respawn_time}", 10, 50, ZOrder::UI, 1.0, 1.0, 0xffffff00) if @player.dead
    @font.draw("Press Space to Start", 300, 500, ZOrder::UI, 1.0, 1.0, 0xffffff00) if @game_over_flag
    @font.draw("Game Over", 350, 300, ZOrder::UI, 1.0, 1.0, 0xffffff00) if @game_over_flag
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
  
  def update_ingame
    read_player_input if @player.active?
    @player.update

    @bullet_manager.update
    @asteroid_manager.update
    
    test_player_asteroid_collisions if @player.active?
    
    bullets = @bullet_manager.bullets
    bullets.each do |bullet|
      test_bullet_asteroid_collision(bullet)
    end
  end

  def update_title_screen
    if @game_controller.fire_weapon_down?
      @lives = PlayerLives
      @score = 0
      @player.prepare_player
      
      @game_over_flag = false
      @asteroid_manager.start_new_wave
    end  
  end
  
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

      if @lives < 0 then
        @game_over_flag = true
        @lives = 0
        
        @asteroid_manager.reset_asteroids
        @bullet_manager.reset_bullets
      end
    end
  end
end

window = AsteroidsGameWindow.new
window.show