local C = require("src/constants")
local loaded = false

function love.load()
	World = love.physics.newWorld(0, 0, true)
	BGImage = love.graphics.newImage("assets/background.png")
	ButterDog = require("src/butterdog")
	ButterNova = require("src/butternova")
	MapBorder = require("src/mapborder")
	Timer = require("src/timer")
	EvilDog = require("src/evilButterDogSlow")
	Videos = require("src/videos")
	LoadingScreen = love.graphics.newImage("assets/loading.png")
	LoadingBar = require("src/loadingbar")
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
	LoadingBar.update(dt)
	if loaded then
		ButterDog:update(dt)
		EvilDog:update(dt)
		Videos.update(dt)
	end
end
function love.draw()
	love.graphics.draw(BGImage)
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
	EvilDogs.draw()
	Videos.draw()
	love.graphics.print("Time: " .. math.floor(Timer:get()) .. "s", 10, 10)
	if Timer:get() < C.LOADING_TIME and not loaded then
		love.graphics.draw(LoadingScreen)
		LoadingBar.draw()
	elseif Timer:get() > C.LOADING_TIME then
		Timer:reset()
		loaded = true
	end
end
