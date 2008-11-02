require 'game_constants'
require 'game_object'
require 'conversions'

class Asteroid < GameObject
  include GameConstants
  
  attr_accessor :asteroid_size
  
  def initialize(asteroid_image)
    super(asteroid_image)
    @angle_rotation = (rand(AsteroidRotationSpeed * 2) - AsteroidRotationSpeed)
    @asteroid_size = :small
  end
  
  def set_forward_velocity(velocity)
    angle_in_rad = Conversions.transform_degrees_to_radians(@angle - 90)
    
    @velocity_x = Math.cos(angle_in_rad)
    @velocity_y = Math.sin(angle_in_rad)
  end
  
  def update
    super
    @angle = Conversions.limit_angle((@angle + @angle_rotation))
  end
end