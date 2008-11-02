require 'game_constants'
require 'game_object'
require 'conversions'

class Asteroid < GameObject
  include GameConstants
  
  attr_accessor :asteroid_size, :object_image
  
  def initialize(asteroid_size, asteroid_image, bounding_sphere_radius)
    super(asteroid_image, bounding_sphere_radius)
    @asteroid_size = asteroid_size
    @angle_rotation = (rand(AsteroidRotationSpeed * 2) - AsteroidRotationSpeed)
  end
  
  def set_forward_velocity(velocity)
    angle_in_rad = Conversions.transform_degrees_to_radians(@angle - 90)
    
    @velocity_x = Math.cos(angle_in_rad)
    @velocity_y = Math.sin(angle_in_rad)
  end

  def set_asteroid_size_and_image(asteroid_size, asteroid_image)
    @asteroid_size = asteroid_size
    @object_image = asteroid_image
  end
  
  def update
    super
    @angle = Conversions.limit_angle((@angle + @angle_rotation))
  end
end