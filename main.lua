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
    ButterDog:update(dt)
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
