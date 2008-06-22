require 'game_constants'
require 'bounds'

module Conversions
  
  # Transforms a coordinate (component) from the world coordinate scale to screen coordinates
  # This is a very simple conversion, assuming a basic linear scale from the world coordinates
  # to the screen coordinates
  def Conversions.transform_world_to_screen(world_position, screen_width, min_world_boundary)
    world_offset = 0 - min_world_boundary
    (world_position + world_offset)
  end
  
  # Does the conversion from the screen coordinates, to a world-based coordinate scale.
  # Again, a simple conversion doing a linear transformation from screen coordinates to world
  # coordinates
  def Conversions.transform_screen_to_world(screen_position, screen_width, min_world_boundary)
    world_offset = 0 - min_world_boundary
    (screen_position - world_offset)
  end
  
  # Converts an angle in degrees to an angle in radians
  # (this is needed to doing the velocity calculations)
  # using the following formula:
  # angle_radians = 2 * Math.PI * angle_degrees / 360
  def Conversions.transform_degrees_to_radians(angle_in_degrees)
    (Math::PI * 2 * angle_in_degrees) / 360
  end
  
  # Limits an angle from the range 0 -> 360 degrees.
  def Conversions.limit_angle(angle)
    angle % 360.0
  end
  
end