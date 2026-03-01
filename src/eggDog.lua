local C = require("src/constants")
local player = require("src/butterdog")
local timer = require("src/timer")

eggDogs = { instances = {} }
local Bullets = require("src/bullets")

--Spawns an enemy at a random spot.
local function spawn()
	eggDog.img = love.graphics.newImage("assets/eggDog.png")

	local where = love.math.random(0, 4)

	--Sets the spawn location of the enemy dog
	if where == 1 then --Spawn left side
		eggDog.x = -200
		eggDog.y = love.math.random(0, C.WINDOW_HEIGHT)
	elseif where == 2 then --Spawn right side
		eggDog.x = C.WINDOW_WIDTH + 50
		eggDog.y = love.math.random(0, C.WINDOW_HEIGHT)
	elseif where == 3 then --Spawn up
		eggDog.x = love.math.random(0, C.WINDOW_WIDTH)
		eggDog.y = -200
	else --Spawn down
		eggDog.x = love.math.random(0, C.WINDOW_WIDTH)
		eggDog.y = C.WINDOW_HEIGHT + 50
	end

	local instance = {
		image = eggDog.img,
		x = eggDog.x,
		y = eggDog.y,
		speed = C.EGG_DOG_SPEED,
		shootCooldown = love.math.random() * 2.0,
		scale = C.EVIL_CLOSE_SCALE,
	}

	table.insert(eggDogs.instances, instance)
end

--Updates each of the eggDog's positions
function eggDogs:update(dt)
	local playerX = player.body:getX()
	local playerY = player.body:getY()

	for i, v in ipairs(eggDogs.instances) do
		--Vector toward player
		local dirX = playerX - v.x
		local dirY = playerY - v.y
		local dist = math.sqrt(dirX * dirX + dirY * dirY)

		--desired distance to keep from player (in pixels)
		local desiredDist = 250
		local tolerance = 4 -- small band to avoid jitter

		if dist > 0 then
			--normalized direction
			local nx = dirX / dist
			local ny = dirY / dist

			if dist > desiredDist + tolerance then
				--too far: move toward player
				v.x = v.x + nx * v.speed * dt
				v.y = v.y + ny * v.speed * dt
			elseif dist < desiredDist - tolerance then
				--too close: move away from player
				v.x = v.x - nx * v.speed * dt
				v.y = v.y - ny * v.speed * dt
			end
		end

		-- shooting: decrement cooldown and fire at player when ready
		v.shootCooldown = (v.shootCooldown or 0) - dt
		local shootInterval = 5.0 -- seconds between shots (tweakable)
		if v.shootCooldown <= 0 then
			local sx = playerX - v.x
			local sy = playerY - v.y
			local sl = math.sqrt(sx * sx + sy * sy)
			if sl > 0 then
				sx = sx / sl
				sy = sy / sl
				Bullets.spawn(v.x, v.y, sx, sy, false)
				v.shootCooldown = shootInterval
			end
		end

		--Checks if the eggDog contacts the player
		local playerBoundX = player.img:getWidth() * player.scale
		local playerBoundY = player.img:getHeight() * player.scale
		local enemyBoundX = eggDogs.instances[i].image:getWidth() * eggDogs.instances[i].scale
		local enemyBoundY = eggDogs.instances[i].image:getHeight() * eggDogs.instances[i].scale

		if math.abs(playerX - v.x) < playerBoundX then
			if math.abs(playerY - v.y) < playerBoundY then
				table.remove(eggDogs.instances, i)
				if player.health == 1 then
					lost = true
				else
					if not C.UNKILLABLE then
						player.health = player.health - 1
					end
				end
			end
		end
end

-- spawn timer (scales over game progress similar to src/videos.lua)
local function currentSpawnRange()
    local elapsed = 0
    if timer and timer.get then
        elapsed = timer:get()
    end
    local progress = 0
    if C.GAME_TIME_LENGTH and C.GAME_TIME_LENGTH > 0 then
        progress = math.min(math.max(elapsed / C.GAME_TIME_LENGTH, 0), 1)
    end
    local curMax = C.SPAWN_MAX - progress * (C.SPAWN_MAX - C.SPAWN_MIN)
    local curMin = C.SPAWN_MIN
    -- Apply global dog spawn rate multiplier (higher => more frequent)
    curMin = curMin / (C.DOG_SPAWN_RATE or 1.0)
    curMax = curMax / (C.DOG_SPAWN_RATE or 1.0)
    return curMin, curMax
end

local function pickNextSpawn()
    local minS, maxS = currentSpawnRange()
    return math.random() * (math.max(maxS - minS, 0)) + minS
end

local spawnTimer = eggDogs._spawnTimer or 0
eggDogs._nextSpawn = eggDogs._nextSpawn or pickNextSpawn()

    spawnTimer = spawnTimer + dt
    if spawnTimer >= eggDogs._nextSpawn then
        spawn()
        spawnTimer = 0
        eggDogs._nextSpawn = pickNextSpawn()
    end

eggDogs._spawnTimer = spawnTimer
end

--Draws each of eggDog
function eggDogs.draw()
	for _, v in ipairs(eggDogs.instances) do
		love.graphics.draw(v.image, v.x, v.y, 0, v.scale, v.scale, v.image:getHeight() / 2, v.image:getHeight() / 2)
	end
end

return eggDogs
