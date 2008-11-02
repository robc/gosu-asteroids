require 'game_object'
require 'game_constants'
require 'bounds'

class Bullet < GameObject
  include GameConstants
  
  attr_reader :bullet_life
  
  def initialize(bullet_image, bounding_sphere_radius)
    super(bullet_image, bounding_sphere_radius)

    @bullet_life = bullet_life
  end

  def update
    super
    @bullet_life = @bullet_life - 1
  end

  def prepare_bullet(bullet_life, location_x, location_y, velocity_x, velocity_y, angle)
    @bullet_life = bullet_life
    @location_x = location_x
    @location_y = location_y
    @velocity_x = velocity_x
    @velocity_y = velocity_y
    @angle = angle
    
    set_forward_velocity(BulletVelocity)
  end
  
  private
  def set_forward_velocity(velocity)
    angle_in_rad = Conversions.transform_degrees_to_radians(@angle - 90)
    
    @velocity_x = @velocity_x + Math.cos(angle_in_rad)
    @velocity_y = @velocity_y + Math.sin(angle_in_rad)
  end
end