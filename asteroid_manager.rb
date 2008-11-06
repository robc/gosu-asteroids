require 'game_constants'
require 'asteroid'
require 'conversions'
require 'bounds'

class AsteroidManager
  include GameConstants, Conversions, Bounds
  
  attr_reader :wave_number
  
  def initialize(pool_size, large_asteroid_image, medium_asteroid_image, small_asteroid_image)
    @asteroid_images = Hash.new()
    @asteroid_images[:large] = large_asteroid_image
    @asteroid_images[:medium] = medium_asteroid_image
    @asteroid_images[:small] = small_asteroid_image

    @bounding_sphere_radius = Hash.new()
    @bounding_sphere_radius[:large] = LargeAsteroidBoundingSphereRadius
    @bounding_sphere_radius[:medium] = MediumAsteroidBoundingSphereRadius
    @bounding_sphere_radius[:small] = SmallAsteroidBoundingSphereRadius

    @active_asteroids = Array.new()
    @asteroid_pool = Array.new(pool_size) do |asteroid|
      asteroid = Asteroid.new(:large, large_asteroid_image, @bounding_sphere_radius[:large])
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
    number_of_asteroids = 11 if number_of_asteroids > 11
    
    number_of_asteroids.times do |counter|
      asteroid = spawn_asteroid(:large)
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
  
  def test_for_collision(object_to_test, remove_asteroid_on_collision)
    collision = false

    @active_asteroids.each do |asteroid|
      radius = object_to_test.bounding_sphere_radius.to_i + asteroid.bounding_sphere_radius.to_i
      
      distance = Gosu::distance(
          object_to_test.location_x.to_i,
          object_to_test.location_y.to_i,
          asteroid.location_x.to_i,
          asteroid.location_y.to_i)

      collision = (distance <= radius)
      if collision
        if remove_asteroid_on_collision
          size = asteroid.asteroid_size
          location_x = asteroid.location_x
          location_y = asteroid.location_y
          
          remove_asteroid(asteroid)
          spawn_child_asteroids(size, location_x, location_y)
        end  
        
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
  def get_random_boolean
    (rand(2) == 1 ? true : false) 
  end
  
  def spawn_asteroid(size)
    asteroid = @asteroid_pool.pop

    asteroid.asteroid_size = size
    asteroid.bounding_sphere_radius = @bounding_sphere_radius[size]
    asteroid.object_image = @asteroid_images[size]
    asteroid.angle = rand(360)
    asteroid.set_forward_velocity(AsteroidForwardVelocity)

    # Do we want to spawn on the side, or on the top?
    spawn_horizontal = get_random_boolean
    if spawn_horizontal then
      asteroid.location_x = (get_random_boolean ? MinPlayfieldHorizontalBound : MaxPlayfieldHorizontalBound)
      asteroid.location_y = Conversions.transform_screen_to_world(rand(ScreenHeight), ScreenHeight, MinVisibleVerticalBound)
    else
      asteroid.location_y = (get_random_boolean ? MinPlayfieldVerticalBound : MaxPlayfieldVerticalBound)
      asteroid.location_x = Conversions.transform_screen_to_world(rand(ScreenWidth), ScreenWidth, MinVisibleHorizontalBound)
    end
    
    asteroid
  end
  
  def spawn_child_asteroids(size, location_x, location_y)
    child_size = get_child_size_for_asteroid_size(size)
    return if child_size == nil
    2.times do
      asteroid = spawn_asteroid(child_size)
      asteroid.location_x = location_x
      asteroid.location_y = location_y
      @active_asteroids << asteroid
    end
  end
  
  # I'm not the biggest fan of this function's implementation, but well
  # I'm a bit stumped for ideas :)
  def get_child_size_for_asteroid_size(size)
    return :medium if size == :large
    return :small if size == :medium
    return nil if size == :small
  end
end