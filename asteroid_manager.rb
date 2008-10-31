require 'game_constants'
require 'asteroid'
require 'conversions'
require 'bounds'

class AsteroidManager
  include GameConstants, Conversions, Bounds
  
  def initialize(num_of_asteroids, asteroid_image)
    @number_of_asteroids = num_of_asteroids
    
    @active_asteroids = Array.new()
    @asteroid_pool = Array.new(num_of_asteroids) do |asteroid|
      asteroid = Asteroid.new(asteroid_image)
    end
    
    @start_new_wave = false
    @new_wave_countdown = 0
  end
  
  def has_active_asteroids?
    !@active_asteroids.empty?
  end
  
  def preparing_for_new_wave?
    @start_new_wave and @new_wave_countdown >= 0
  end
  
  def start_new_wave
    puts "Starting New Wave of asteroids"
    @start_new_wave = true
    @new_wave_countdown = NewWaveDelay
  end
  
  def initialise_wave
    @number_of_asteroids.times do |counter|
      asteroid = @asteroid_pool.pop
    
      # sets up the location for the asteroid to spawn (ideally, we want them to spawn on the borders)
      location_x, location_y  = 0
      spawn_horizontal = rand(1)
      if spawn_horizontal then
        location_x = Conversions.transform_screen_to_world(rand(ScreenWidth), ScreenWidth, MinVisibleHorizontalBound)
        y = rand(2 * BoundsBufferSize)
        location_y = MinVisibleVerticalBound + y if y <= BoundsBufferSize
        location_y = MaxVisibleVerticalBound - y if y > BoundsBufferSize 
      else
        location_y = Conversions.transform_screen_to_world(rand(ScreenHeight), ScreenHeight, MinVisibleVerticalBound)
        x = rand(2 * BoundsBufferSize)
        location_x = MinVisibleHorizontalBound + x if x <= BoundsBufferSize
        location_x = MaxVisibleHorizontalBound - x if x > BoundsBufferSize 
      end

      angle = rand(360)
    
      asteroid.prepare_asteroid(location_x, location_y, angle)
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
      if collision and remove_asteroid_on_collision
        remove_asteroid(asteroid)
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
  def distance_between_two_points(x1, y1, x2, y2)
    x_delta = x2 - x1
    y_delta = y2 - y1
    
    x_delta_squared = x_delta.power!(2)
    y_delta_squared = y_delta.power!(2)
    
    summed_deltas = x_delta_squared + y_delta_squared
    Math.sqrt(summed_deltas) 
  end
  
end