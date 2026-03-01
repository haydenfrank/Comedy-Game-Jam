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
					player.health = player.health - 1
				end
			end
		end
	end

	local randomOne = 0
	if 5 - timer.time * 0.05 > 0 then
		randomOne = love.math.random(0, 5 - timer.time * 0.05)
	end

	local randomTwo = love.math.random(0, 15)
	if randomOne == 0 and randomTwo == 0 then
		spawn()
	end
end

--Draws each of eggDog
function eggDogs.draw()
	for _, v in ipairs(eggDogs.instances) do
		love.graphics.draw(v.image, v.x, v.y, 0, v.scale, v.scale, v.image:getHeight() / 2, v.image:getHeight() / 2)
	end
end

return eggDogs
