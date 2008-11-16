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
    @asset_manager.background_image.draw(0, 0, ZOrder::Background)
    @asset_manager.title_font.draw("Press Space to Play", 225, 300, ZOrder::UI, 1, 1, 0xffffffff)
  end
end