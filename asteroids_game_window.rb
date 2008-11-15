require 'rubygems'
require 'gosu'
require 'player'
require 'game_constants'
require 'bounds'
require 'bullet_manager'
require 'asteroid_manager'
require 'lib/game_controller'
require 'lib/asset_manager'
require 'screens/title_screen'

module ZOrder
  Background, Asteroids, Player, UI = *0..3
end

class AsteroidsGameWindow < Gosu::Window
  include GameConstants, Bounds
  
  attr_accessor :active_screen
  
  def initialize
    super(ScreenWidth, ScreenHeight, false)
    self.caption = "Asteroids Game"

    @asset_manager = AssetManager.new
    
    @asset_manager.background_image = Gosu::Image.new(self, "media/IngameBackground.png", true)
    @asset_manager.font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    
    @asset_manager.player_image = Gosu::Image.new(self, "media/Spaceship.png", true)
    @asset_manager.bullet_image = Gosu::Image.new(self, "media/Bullet.png", true)
    @asset_manager.large_asteroid_image = Gosu::Image.new(self, "media/AsteroidLarge.png", true)
    @asset_manager.medium_asteroid_image = Gosu::Image.new(self, "media/AsteroidMedium.png", true)
    @asset_manager.small_asteroid_image = Gosu::Image.new(self, "media/AsteroidSmall.png", true)
    
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
    
    @active_screen = TitleScreen.new(self, @game_controller, @asset_manager, ScreenWidth, ScreenHeight)
  end

  def update
    @active_screen.update if !@active_screen.nil?
  end

  def draw
    @active_screen.draw if !@active_screen.nil?
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
end

window = AsteroidsGameWindow.new
window.show