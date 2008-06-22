require 'game_constants'

module Bounds
  include GameConstants
  
  MinVisibleHorizontalBound = -(ScreenWidth / 2)
  MaxVisibleHorizontalBound =  (ScreenWidth / 2)
  MinVisibleVerticalBound = -(ScreenHeight / 2)
  MaxVisibleVerticalBound =  (ScreenHeight / 2)
end