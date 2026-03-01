local C = require("src/constants")
local loaded = false
local won = false

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
	Xiao = require("src/xiaoSpawn")
	WinScreen = love.graphics.newImage("assets/game-win.png")
end

function love.keypressed(key)
	if key == "r" and (lost == true or won == true) then
		love.event.push("quit", "restart")
	end

	if key == "space" and loaded and not lost then
		local mx, my = love.mouse.getPosition()
		if ButterDog and ButterDog.shootAt then
			ButterDog:shootAt(mx, my)
			sound = love.audio.newSource("assets/shoot.ogg", "static")
			sound:setVolume(0.45)
			sound:play()
		end
	end
	-- if key == "k" and loaded then -- for debug, skip to boss fight
	-- 	Timer:set(C.GAME_TIME_BOSS_START)
	-- end
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

local flashTime = 1
local noFlashTime = 1
local flashed = false
local startFlashCount = false
local startNoFlashCount = false

function love.update(dt)
	if Timer.time >= C.GAME_TIME_LENGTH then
		won = true
	end

	if not lost and not won then
		World:update(dt)
		Timer:update(dt)
		LoadingBar.update(dt)
		if loaded then
			ButterDog:update(dt)
			EvilDog:update(dt)
			eggDogs:update(dt)
			Bullets.update(dt, EvilDogs.instances)
			Bullets.update(dt, eggDogs.instances)
			Xiao.update(dt)
			Videos.update(dt)
			Health.update(dt)
			ProgressBar.update(dt)

			--Count for flashing the INCOMING message
			if startFlashCount == true then
				flashTime = flashTime - dt
			end

			if startNoFlashCount == true then
				noFlashTime = noFlashTime - dt
			end
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

	EvilDogs.draw()
	eggDogs.draw()

	Xiao.draw()

	Bullets.draw()
	ProgressBar.draw()

	Health.draw()

	Videos.draw()
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

	--If the game is at boss start, flash the INCOMING for 5 seconds
	if Timer:get() > C.GAME_TIME_BOSS_START and Timer:get() <= C.GAME_TIME_BOSS_START + 5 and not lost then
		if not flashed then
			startFlashCount = true
			if flashTime < 0 then
				flashTime = 2
				flashed = true
			end
			love.graphics.draw(Warning)
		end

		if flashed then
			startNoFlashCount = true
			if noFlashTime < 0 then
				noFlashTime = 2
				flashed = false
			end
		end
	end
	if lost then
		love.graphics.draw(GameOver)
	end
	if won then
		love.graphics.draw(WinScreen)
	end
end
