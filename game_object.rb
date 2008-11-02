require 'game_constants'
require 'conversions'
require 'bounds'

class GameObject
  include GameConstants, Conversions, Bounds
  
  attr_accessor   :location_x, :location_y
  attr_reader     :velocity_x, :location_y
  attr_accessor   :angle, :bounding_sphere_radius
  
  def initialize(image, bounding_sphere_radius)
    @object_image = image
    @bounding_sphere_radius = bounding_sphere_radius
    set_location_velocity_angle_defaults
  end
  
  def draw
    x = Conversions.transform_world_to_screen(@location_x, ScreenWidth, MinVisibleHorizontalBound)
    y = Conversions.transform_world_to_screen(@location_y, ScreenHeight, MinVisibleVerticalBound)

    @object_image.draw_rot(x, y, ZOrder::Player, @angle)
  end
  
  def update
    @location_x += @velocity_x
    @location_y += @velocity_y
    
    horizontal_wrap if @location_x <= (MinVisibleHorizontalBound - BoundsBufferSize) || @location_x >= (MaxVisibleHorizontalBound + BoundsBufferSize)
    vertical_wrap if @location_y <= (MinVisibleVerticalBound - BoundsBufferSize) || @location_y >= (MaxVisibleVerticalBound + BoundsBufferSize)
  end
  
  protected
  def set_location_velocity_angle_defaults
    @location_x = 0
    @location_y = 0
    
    @velocity_x = 0
    @velocity_y = 0
    
    @angle = 0
  end
  
  # Recalculates the straight-line of an object so that it does not exceed a
  # particular velocity amount
  def clamp_velocity(max_velocity, current_velocity)
    # Gives us a ratio of how far we've above the max velocity
    velocity_ratio = max_velocity / current_velocity
    
    @velocity_x *= velocity_ratio
    @velocity_y *= velocity_ratio
  end
  
  # Updates the location of an object so that it wraps around the left/right sides of the screen
  def horizontal_wrap
    @location_x = (MaxVisibleHorizontalBound + BoundsBufferSize) if (@location_x < MinVisibleHorizontalBound - BoundsBufferSize)
    @location_x = (MinVisibleHorizontalBound - BoundsBufferSize) if (@location_x > MaxVisibleHorizontalBound + BoundsBufferSize)
  end
  
  # Updates the location of an object so that it wraps around the top/bottom of the screen
  def vertical_wrap
    @location_y = (MaxVisibleVerticalBound + BoundsBufferSize) if (@location_y < MinVisibleVerticalBound - BoundsBufferSize)
    @location_y = (MinVisibleVerticalBound - BoundsBufferSize) if (@location_y > MaxVisibleVerticalBound + BoundsBufferSize)
  end
  
end