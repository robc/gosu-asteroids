require 'rubygems'
require 'gosu'
require 'player'
require 'game_constants'
require 'bounds'
require 'bullet_manager'
require 'asteroid_manager'

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
    
    @game_over_flag = true
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
    if button_down? Gosu::Button::KbSpace or button_down? Gosu::Button::GpButton0 then
      @lives = PlayerLives
      @score = 0
      @player.prepare_player
      
      @game_over_flag = false
      @asteroid_manager.start_new_wave
    end  
  end
  
  def read_player_input
    if button_down? Gosu::Button::KbLeft or button_down? Gosu::Button::GpLeft then
      @player.turn_left
    elsif button_down? Gosu::Button::KbRight or button_down? Gosu::Button::GpRight then
      @player.turn_right
    end

    if button_down? Gosu::Button::KbUp or button_down? Gosu::Button::GpButton0 then
      @player.fire_thrust
    else
      @player.slow_down
    end

    if button_down? Gosu::Button::KbLeftShift or button_down? Gosu::Button::GpButton1 then
      @player.hyperspace
    end
    
    if (button_down? Gosu::Button::KbSpace or button_down? Gosu::Button::GpButton2) and !@bullet_fired and !@player.in_hyperspace then
      @bullet_manager.fire_bullet(@player.location_x, @player.location_y, @player.velocity_x, @player.velocity_y, @player.angle)
      @bullet_fired = true
    else
      @bullet_fired = false
    end
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