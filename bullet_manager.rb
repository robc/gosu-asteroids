require 'game_constants'
require 'bullet'
require 'pp'

class BulletManager
  include GameConstants

  def initialize(number_of_bullets, bullet_image, bullet_bounding_sphere_radius)
    @active_bullets = Array.new()
    @bullet_pool = Array.new(number_of_bullets) do |counter|
      Bullet.new(bullet_image, bullet_bounding_sphere_radius)
    end
  end
  
  def bullets
    @active_bullets
  end
  
  def fire_bullet(location_x, location_y, velocity_x, velocity_y, angle)
    bullet = @bullet_pool.pop
    
    if bullet
      bullet.prepare_bullet(BulletLifeCycle, location_x, location_y, velocity_x, velocity_y, angle)
      @active_bullets << bullet
    end
  end
  
  def remove_bullet(bullet)
    @bullet_pool << bullet
    @active_bullets.delete(bullet)
  end
  
  def reset_bullets
    @active_bullets.each do |bullet|
      @bullet_pool << bullet
    end
    @active_bullets.clear
  end
  
  def update
    @active_bullets.each do |bullet|
      bullet.update

      if bullet.bullet_life <= 0
        @active_bullets.delete(bullet)
        @bullet_pool << bullet
      end
    end
  end
  
  def draw
    @active_bullets.each do |bullet|
      bullet.draw
    end
  end
end