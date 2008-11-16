module GameConstants
  FrameTime = 1.0 / 60.0

  ScreenWidth  = 1024
  ScreenHeight = 768
  BoundsBufferSize = 50
  BulletFireDelay = 20

  LargeAsteroidBoundingSphereRadius = 56
  MediumAsteroidBoundingSphereRadius = 28
  SmallAsteroidBoundingSphereRadius = 14

  PlayerBoundingSphereRadius = 17
  BulletBoundingSphereRadius = 6

  PlayerLives = 3
  MaxForwardVelocity = 81.0
  MaxForwardThrust = 5.0
  DeaccelerationRate = 0.98
  HyperspaceTime = 120
  PlayerRotationVelocity = 180.0

  BulletLifeCycle = 240
  BulletVelocity = 2000
  NumberOfBullets = 6

  PlayerRespawnTime = 180
  NewWaveDelay = 120
  
  MinAsteroidsToSpawn = 4
  MaxAsteroidsInPool = 50
  AsteroidScore = 75
  
  LargeAsteroidForwardVelocity = 10
  MediumAsteroidForwardVelocity = 30
  SmallAsteroidForwardVelocity = 50
  
  LargeAsteroidScore = 20
  MediumAsteroidScore = 50
  SmallAsteroidScore = 100
  
  AsteroidRotationSpeed = 0.25
end
