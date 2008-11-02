require 'game_constants'
require 'asteroid'
require 'conversions'
require 'bounds'

class AsteroidManager
  include GameConstants, Conversions, Bounds
  
  attr_reader :wave_number
  
  def initialize(pool_size, asteroid_image)
    @active_asteroids = Array.new()
    @asteroid_pool = Array.new(pool_size) do |asteroid|
      asteroid = Asteroid.new(asteroid_image)
    end
    
    @start_new_wave = false
    @new_wave_countdown = 0
    @wave_number = 0
  end
  
  def has_active_asteroids?
    !@active_asteroids.empty?
  end
  
  def preparing_for_new_wave?
    @start_new_wave and @new_wave_countdown >= 0
  end
  
  def start_new_wave
    @start_new_wave = true
    @new_wave_countdown = NewWaveDelay
    @wave_number += 1
  end
  
  def initialise_wave
    number_of_asteroids = (2 * (@wave_number - 1)) + MinAsteroidsToSpawn
    
    number_of_asteroids.times do |counter|
      asteroid = @asteroid_pool.pop

      # Do we want to spawn on the side, or on the top?
      spawn_horizontal = get_random_boolean
      if spawn_horizontal then
        asteroid.location_x = (get_random_boolean ? MinPlayfieldHorizontalBound : MaxPlayfieldHorizontalBound)
        asteroid.location_y = Conversions.transform_screen_to_world(rand(ScreenHeight), ScreenHeight, MinVisibleVerticalBound)
      else
        asteroid.location_y = (get_random_boolean ? MinPlayfieldVerticalBound : MaxPlayfieldVerticalBound)
        asteroid.location_x = Conversions.transform_screen_to_world(rand(ScreenWidth), ScreenWidth, MinVisibleHorizontalBound)
      end

      asteroid.angle = rand(360)
      asteroid.set_forward_velocity(AsteroidForwardVelocity)
      @active_asteroids << asteroid
    end
  end
  
  def reset_asteroids
    @active_asteroids.each do |asteroid|
      @asteroid_pool << asteroid
    end

    @active_asteroids.clear
  end
  
  def remove_asteroid(asteroid)
    @asteroid_pool << asteroid
    @active_asteroids.delete(asteroid)
  end
  
  def test_for_collision(object_location_x, object_location_y, radius, remove_asteroid_on_collision)
    collision = false
    
    @active_asteroids.each do |asteroid|
      distance = distance_between_two_points(
          object_location_x.to_i,
          object_location_y.to_i,
          asteroid.location_x.to_i,
          asteroid.location_y.to_i)

      collision = (distance <= radius)
      if collision
        remove_asteroid(asteroid) if remove_asteroid_on_collision
        break
      end
    end

    collision
  end
  
  def update
    if @start_new_wave
      if @new_wave_countdown < 0
        @start_new_wave = false
        initialise_wave
      end

      @new_wave_countdown = @new_wave_countdown - 1
    else
      @active_asteroids.each do |asteroid|
        asteroid.update
      end
    end
  end
  
  def draw
    @active_asteroids.each do |asteroid|
      asteroid.draw
    end
  end
  
  private
  # TODO: Extract me out into a library!
  # (NB: Gosu apparently has it's own implementation - maybe wanna compare it?)
  def distance_between_two_points(x1, y1, x2, y2)
    x_delta = x2 - x1
    y_delta = y2 - y1
    
    x_delta_squared = x_delta.power!(2)
    y_delta_squared = y_delta.power!(2)
    
    summed_deltas = x_delta_squared + y_delta_squared
    Math.sqrt(summed_deltas) 
  end
  
  def get_random_boolean
    (rand(2) == 1 ? true : false) 
  end
  
end