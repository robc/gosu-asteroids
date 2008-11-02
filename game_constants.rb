module GameConstants
  ScreenWidth  = 1024
  ScreenHeight = 768
  BoundsBufferSize = 50

  PlayerBoundingSphereRadius = 17
  AsteroidBoundingSphereRadius = 28
  BulletBoundingSphereRadius = 6

  PlayerAsteroidCollisionRadius = (PlayerBoundingSphereRadius + AsteroidBoundingSphereRadius)
  BulletAsteroidCollisionRadius = (AsteroidBoundingSphereRadius + BulletBoundingSphereRadius)

  PlayerLives = 3
  MaxForwardVelocity = 40
  DeaccelerationRate = 0.97
  HyperspaceTime = 120

  BulletLifeCycle = 150
  BulletVelocity = 150
  NumberOfBullets = 3

  PlayerRespawnTime = 60
  NewWaveDelay = 90
  
  MinAsteroidsToSpawn = 4
  MaxAsteroidsInPool = 50
  AsteroidForwardVelocity = 30
  AsteroidScore = 500
  
  SmallAsteroidForwardVelocity = 40
  MediumAsteroidForwardVelocity = 25
  LargeAsteroidForwardVelocity = 10
  
  AsteroidRotationSpeed = 0.25
end
