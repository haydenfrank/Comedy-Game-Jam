local C = require("src/constants")

ButterDog = {health = 3}
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

function ButterDog:update(dt)
	local vx, vy = 0, 0
	if love.keyboard.isDown("d") then
		vx = vx + 1
	end
	if love.keyboard.isDown("a") then
		vx = vx - 1
	end
	if love.keyboard.isDown("s") then
		vy = vy + 1
	end
	if love.keyboard.isDown("w") then
		vy = vy - 1
	end
	if vx == 0 and vy == 0 then
		self.body:setLinearVelocity(0, 0)
	else
		local len = math.sqrt(vx * vx + vy * vy)
		vx = vx / len * self.speed
		vy = vy / len * self.speed
		self.body:setLinearVelocity(vx, vy)
	end
	
end

return ButterDog
