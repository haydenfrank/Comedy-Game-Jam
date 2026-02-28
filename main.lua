function love.load()
	local C = require("src/constants")
	World = love.physics.newWorld(0, 0, true)
	ButterDog = require("src/butterdog")
	ButterNova = require("src/butternova")
	MapBorder = require("src/mapborder")
	Timer = require("src/timer")
	Videos = require("src/videos")
end

function love.keypressed() end

function love.mousepressed(x, y, button)
    -- forward mouse clicks to the Videos module so popups can be closed
    if Videos and Videos.mousepressed then
        Videos.mousepressed(x, y, button)
    end
end

function love.update(dt)
    World:update(dt)
    Timer:update(dt)
    ButterDog:update(dt)
    Videos.update(dt)
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
    Videos.draw()
	love.graphics.print("Time: " .. math.floor(Timer:get()) .. "s", 10, 10)
end
