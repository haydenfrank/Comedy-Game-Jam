local C = require("src/constants")
local timer = require("src/timer")

local Xiao = {}
local xiaoImage = love.graphics.newImage("assets/xiao-pang.png")
local animationDone = false
local animationTime = 0
local xiaoX = C.WINDOW_WIDTH
local xiaoY = C.WINDOW_HEIGHT / 3
local xiaoScale = 2
local Bullets = require("src/bullets")
local concrete = love.audio.newSource("assets/concrete.ogg", "static")
local siren = love.audio.newSource("assets/siren.ogg", "static")
concrete:setVolume(0.5)
siren:setVolume(0.5)
local played = 0

-- boss state
local bossActive = false
local bossHealth = 30
local bossTimer = 0
local nextLaserAt = 0
local laserRemaining = 0
local laserTick = 0
local nextSpreadAt = 0

function Xiao.update(dt)
    if(C.GAME_TIME_BOSS_START <= timer.time) then
        bossActive = true
        animationTime = animationTime + dt
        if(animationTime > 5) then
            animationDone = true
        end
        if(not animationDone) then
            xiaoX = xiaoX - dt * 60
        end
        if bossActive and animationDone then
            bossTimer = bossTimer + dt

			-- laser attack (stream of images)
			if bossTimer >= nextLaserAt then
				laserRemaining = C.XIAO_LASER_DURATION
				laserTick = 0
				nextLaserAt = bossTimer + C.XIAO_LASER_COOLDOWN
			end

			if laserRemaining > 0 then
				laserTick = laserTick + dt
				if laserTick >= C.XIAO_LASER_RATE then
					-- spawn a fast stream towards player using random image types
					local px, py = ButterDog.body:getX(), ButterDog.body:getY()
					local dx, dy = px - xiaoX, py - xiaoY
					local l = math.sqrt(dx * dx + dy * dy)
					if l > 0 then
						dx, dy = dx / l, dy / l
						-- cycle through kinds: bread, butter, egg
						-- Xiao should not fire butter; replace butter shots with bread
						local kinds = { "bread", "bread", "egg" }
						local kind = kinds[math.floor(bossTimer * 10) % #kinds + 1]
						Bullets.spawn(xiaoX + 150, xiaoY + 200, dx, dy, false, kind)
					end
					laserTick = 0
				end
				laserRemaining = laserRemaining - dt
			end

			-- spread attack
			if bossTimer >= nextSpreadAt then
				nextSpreadAt = bossTimer + C.XIAO_SPREAD_COOLDOWN
				-- fire spread towards player
				local px, py = ButterDog.body:getX(), ButterDog.body:getY()
				local dx, dy = px - xiaoX, py - xiaoY
				local l = math.sqrt(dx * dx + dy * dy)
				if l > 0 then
					dx, dy = dx / l, dy / l
					local baseAngle = math.atan2(dy, dx)
					local count = C.XIAO_SPREAD_COUNT
					local total = C.XIAO_SPREAD_ANGLE
					for i = 0, count - 1 do
						local t = (i / (count - 1)) - 0.5
						local ang = baseAngle + t * total
						local kx = math.cos(ang)
						local ky = math.sin(ang)
						-- alternating kinds in spread
						-- avoid butter for Xiao's spread; use bread instead
						local kinds = { "egg", "bread", "bread" }
						local kind = kinds[(i % #kinds) + 1]
						Bullets.spawn(xiaoX + 150, xiaoY + 200, kx, ky, false, kind)
					end
				end
			end
		end
	end
end

function Xiao.draw()
	if C.GAME_TIME_BOSS_START <= timer.time then
		love.graphics.draw(xiaoImage, xiaoX, xiaoY, 0, xiaoScale, xiaoScale)
		if played == 0 then
			concrete:play()
			siren:play()
			played = played + 1
		end
	end
end

return Xiao
