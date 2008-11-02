require 'game_constants'
require 'game_object'
require 'conversions'

class Asteroid < GameObject
  include GameConstants
  
  def initialize(asteroid_image)
    super(asteroid_image)
  end
  
  def set_forward_velocity(velocity)
    angle_in_rad = Conversions.transform_degrees_to_radians(@angle - 90)
    
    @velocity_x = Math.cos(angle_in_rad)
    @velocity_y = Math.sin(angle_in_rad)
  end  
end