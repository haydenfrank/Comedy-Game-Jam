function love.load()
	local C = require("src/constants")
	World = love.physics.newWorld(0, 0, true)
	ButterDog = require("src/butterdog")
	ButterNova = require("src/butternova")
	MapBorder = require("src/mapborder")
	Timer = require("src/timer")
end

function love.keypressed() end

function love.update(dt)
	World:update(dt)
	Timer:update(dt)
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
		ButterDog.body:setLinearVelocity(0, 0)
	else
		local len = math.sqrt(vx * vx + vy * vy)
		vx = vx / len * ButterDog.speed
		vy = vy / len * ButterDog.speed
		ButterDog.body:setLinearVelocity(vx, vy)
	end
end
function love.draw()
	love.graphics.draw(
		ButterDog.img,
		ButterDog.body:getX(),
		ButterDog.body:getY(),
		ButterDog.body:getAngle(),
		ButterDog.scale,
		ButterDog.scale,
		ButterDog.img:getWidth() / 2,
		ButterDog.img:getHeight() / 2
	)
	love.graphics.print("Time: " .. math.floor(Timer:get()) .. "s", 10, 10)
end
