require 'bounds'
require 'conversions'
require 'game_object'

class Player < GameObject
  include Conversions, Bounds, GameConstants  

  attr_reader   :in_hyperspace, :dead
  attr_reader   :respawn_time
  attr_reader   :velocity_x, :velocity_y
  
  def initialize(player_image, bounding_sphere_radius)
    super(player_image, bounding_sphere_radius)
    
    prepare_player
  end

  def prepare_player
   @in_hyperspace = false
   @dead = false
   @respawn_time = 0
   
   set_location_velocity_angle_defaults
  end

  def active?
    !in_hyperspace and !dead 
  end

  def turn_left
    @angle -= 2.0
    @angle = Conversions.limit_angle(@angle)
  end

  def turn_right
    @angle += 2.0
    @angle = Conversions.limit_angle(@angle)
  end

  def fire_thrust
    # Transforms the current angle into a radian based angle using the heading with 90 degrees added.
    # This is due to the unit circle being oriented to point at the 90 degree point (meaning our angles are 90 degrees off)
    flight_heading = Conversions.transform_degrees_to_radians(@angle - 90)

    # Grabs the sin & cos of the transformed heading and adds it to the velocity
    horizontal_thrust = Math.cos(flight_heading)
    vertical_thrust = Math.sin(flight_heading)
    
    # Updates the total thrust with the new components
    @velocity_x += horizontal_thrust
    @velocity_y += vertical_thrust
    
    # Checks to see if we're moving too fast (overall), and if so
    # clamps down the thrust to keep it within the limits
    overall_velocity = (@velocity_x * @velocity_x) + (@velocity_y * @velocity_y)
    clamp_velocity(10, overall_velocity) if overall_velocity > MaxForwardVelocity
  end
  
  def hyperspace
    # Not necessarily best practise - we should ideally count down the time using time offsets
    # and not simple frame ticks - but as we do not have a time difference between each frame
    # this is about the easiest solution to implement.
    @respawn_time = 180
    @in_hyperspace = true
    
    # Resets the player's velocity, and goes to randomly reposition the player on the screen
    angle = @angle
    set_location_velocity_angle_defaults
    @angle = angle
    @location_x = rand(ScreenWidth).to_i - (ScreenWidth / 2)
    @location_y = rand(ScreenHeight).to_i - (ScreenHeight / 2)
  end
  
  def kill_player
    @dead = true
    @respawn_time = PlayerRespawnTime
    set_location_velocity_angle_defaults
  end
  
  def slow_down
    @velocity_x = @velocity_x * DeaccelerationRate
    @velocity_y = @velocity_y * DeaccelerationRate
  end
  
  def update
    if @in_hyperspace or @dead then
      @respawn_time = @respawn_time - 1

      @in_hyperspace = false if @respawn_time <= 0
      @dead = false if @respawn_time <= 0
    else
      super
    end
  end
  
  def draw
    super if !@in_hyperspace and !@dead
  end
end