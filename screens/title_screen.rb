require "rubygems"
require "screens/game_screen"

class TitleScreen
  def initialize(game_window, game_controller, asset_manager, width, height)
    @game_window = game_window
    @game_controller = game_controller
    @asset_manager = asset_manager
    
    # TODO: Confirm if we can get these direct from the game_window
    # To be honest, we only need these for positioning.  We might be able to work around that later...
    @width = width
    @height = height
  end

  def update
    # puts "Trying to go to the GameScreen" if @game_controller.fire_weapon_down? 
    @game_window.active_screen = GameScreen.new(@game_window, @game_controller, @asset_manager, @width, @height) if @game_controller.fire_weapon_down?
  end
  
  def draw
    # Would love to do some complex shit here - make it nice and funky :)
    @asset_manager.background_image.draw(0, 0, 0) # Need to reuse the enum type defined in asteroids_game_window    
    @asset_manager.font.draw("Press Space to Play", 300, 500, 3, 1, 1, 0xffffffff)
  end
end