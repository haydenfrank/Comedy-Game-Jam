local C = require("src/constants")
local loaded = false

function love.load()
	love.window.setTitle("ButtaDawg")
	lost = false
	World = love.physics.newWorld(0, 0, true)
	BGImage = love.graphics.newImage("assets/background.png")
	ButterDog = require("src/butterdog")
	Bullets = require("src/bullets")
	ButterNova = require("src/butternova")
	MapBorder = require("src/mapborder")
	Timer = require("src/timer")
	EvilDog = require("src/evilButterDogSlow")
	eggDog = require("src/eggDog")
	Videos = require("src/videos")
	LoadingScreen1 = love.graphics.newImage("assets/loading1.png")
	LoadingScreen2 = love.graphics.newImage("assets/loading2.png")
	LoadingBar = require("src/loadingbar")
	ProgressBar = require("src/progressBar")
	Health = require("src/health")
	GameOver = love.graphics.newImage("assets/gameOver.png")
	Warning = love.graphics.newImage("assets/warning.png")
end

function love.keypressed(key)
	if key == "r" and lost == true then
		love.event.push("quit", "restart")
	end

	if key == "space" and loaded then
		local mx, my = love.mouse.getPosition()
		if ButterDog and ButterDog.shootAt then
			ButterDog:shootAt(mx, my)
			sound = love.audio.newSource("assets/shoot.ogg", "static")
			sound:setVolume(0.45)
			sound:play()
		end
	end
end

function love.mousepressed(x, y, button)
	-- forward mouse clicks to the Videos module so popups can be closed
	if Videos and Videos.mousepressed then
		Videos.mousepressed(x, y, button)
	end

	-- if button == 1 and loaded then
	-- 	if ButterDog and ButterDog.shootAt then
	-- 		ButterDog:shootAt(x, y)
	-- 	end
	-- end
end

function love.update(dt)
	if not lost then
		World:update(dt)
		Timer:update(dt)
		LoadingBar.update(dt)
		if loaded then
			ButterDog:update(dt)
			EvilDog:update(dt)
			eggDogs:update(dt)
			Bullets.update(dt, EvilDogs.instances)
			Bullets.update(dt, eggDogs.instances)
			Videos.update(dt)
			Health.update(dt)
			ProgressBar.update(dt)
		end
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
	Bullets.draw()
	EvilDogs.draw()
	eggDogs.draw()
	ProgressBar.draw()
	Videos.draw()
	Health.draw()

	love.graphics.print("Time: " .. math.floor(Timer:get()) .. "s", 10, 10)
	if Timer:get() < C.LOADING_TIME and not loaded then
		if Timer:get() < C.LOADING_TIME / 2 then
			LoadingScreen = LoadingScreen1
		else
			LoadingScreen = LoadingScreen2
		end
		love.graphics.draw(LoadingScreen)
		LoadingBar.draw()
	elseif Timer:get() > C.LOADING_TIME then
		if not loaded then
			Timer:reset()
		end
		loaded = true
	end
	if Timer:get() > C.GAME_TIME_BOSS_START and Timer:get() <= C.GAME_TIME_BOSS_START + 5 and not lost then
		love.graphics.draw(Warning)
	end
	if lost then
		love.graphics.draw(GameOver)
	end
end
