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
   @acceleration = 0
   
   set_location_velocity_angle_defaults
  end

  def active?
    !in_hyperspace and !dead 
  end

  def turn_left
    @angle -= (PlayerRotationVelocity * FrameTime)
    @angle = Conversions.limit_angle(@angle)
  end

  def turn_right
    @angle += (PlayerRotationVelocity * FrameTime)
    @angle = Conversions.limit_angle(@angle)
  end

  def fire_thrust
    # Sigh.  WTF?
    @acceleration = 1.0
    
    # if @acceleration == 0
    #   @acceleration = 0.5
    # else
    #   @acceleration = @acceleration * 1.3
    # end
    
    update_forward_velocity
  end
  
  def slow_down
    @velocity_x *= DeaccelerationRate
    @velocity_y *= DeaccelerationRate
  end
  
  def update_forward_velocity
    # Get the horizontal & vertical components of the current direction
    flight_heading = Conversions.transform_degrees_to_radians(@angle - 90)
    horizontal_thrust = Math.cos(flight_heading) * (MaxForwardThrust * @acceleration)
    vertical_thrust = Math.sin(flight_heading) * (MaxForwardThrust * @acceleration)

    # puts "Math.cos(flight_heading) * (MaxForwardThrust * @acceleration)"
    # puts "#{Math.cos(flight_heading)} * (#{MaxForwardThrust} * #{@acceleration})"
    # puts "#{Math.cos(flight_heading) * (MaxForwardThrust * @acceleration)}"

    # Updates the velocity using the additional thrust components
    @velocity_x += horizontal_thrust
    @velocity_y += vertical_thrust

    @combined_velocity_vector = (@velocity_x * @velocity_x) + (@velocity_y * @velocity_y)
    clamp_velocity(MaxForwardVelocity, @combined_velocity_vector) if @combined_velocity_vector > MaxForwardVelocity
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