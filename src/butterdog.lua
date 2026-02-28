local C = require("src/constants")

ButterDog = {}
ButterDog.img = love.graphics.newImage("assets/butterdog.png")
-- scale the sprite and physics shape to 1/4 size
ButterDog.scale = C.DOG_SCALE
ButterDog.body = love.physics.newBody(World, 0, 0, "dynamic")
ButterDog.shape = love.physics.newRectangleShape(
	ButterDog.img:getWidth() * ButterDog.scale,
	ButterDog.img:getHeight() * ButterDog.scale
)
ButterDog.fixture = love.physics.newFixture(ButterDog.body, ButterDog.shape)
ButterDog.speed = C.DOG_SPEED
ButterDog.body:setPosition(C.WINDOW_WIDTH / 2, C.WINDOW_HEIGHT / 2)
ButterDog.body:setFixedRotation(true)

return ButterDog
