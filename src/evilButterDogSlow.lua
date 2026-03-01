local C = require("src/constants")
local player = require("src/butterdog")
local timer = require("src/timer")

EvilDogs = { instances = {} }

--Spawns an enemy at a random spot.
local function spawn()
	EvilDog.img = love.graphics.newImage("assets/Evil Butter Dog.png")

	local where = love.math.random(0, 4)

	--Sets the spawn location of the enemy dog
	if where == 1 then --Spawn left side
		EvilDog.x = -200
		EvilDog.y = love.math.random(0, C.WINDOW_HEIGHT)
	elseif where == 2 then --Spawn right side
		EvilDog.x = C.WINDOW_WIDTH + 50
		EvilDog.y = love.math.random(0, C.WINDOW_HEIGHT)
	elseif where == 3 then --Spawn up
		EvilDog.x = love.math.random(0, C.WINDOW_WIDTH)
		EvilDog.y = -200
	else --Spawn down
		EvilDog.x = love.math.random(0, C.WINDOW_WIDTH)
		EvilDog.y = C.WINDOW_HEIGHT + 50
	end

	local instance = {
		image = EvilDog.img,
		x = EvilDog.x,
		y = EvilDog.y,
		speed = C.EVIL_CLOSE_SPEED,
		scale = C.EVIL_CLOSE_SCALE,
	}

	table.insert(EvilDogs.instances, instance)
end

--Updates each of the EvilDog's positions
function EvilDogs:update(dt)
	local playerX = player.body:getX()
	local playerY = player.body:getY()

	for i, v in ipairs(EvilDogs.instances) do
		--Vector for movement position
		local dirX = playerX - v.x
		local dirY = playerY - v.y

		--Normalizes movement
		local length = math.sqrt(dirX * dirX + dirY * dirY)
		if length > 1 then
			dirY = dirY / length
			dirX = dirX / length
		end

		--Sets the new position for the current EvilDog
		v.x = v.x + dirX * v.speed * dt
		v.y = v.y + dirY * v.speed * dt

		--Checks if the EvilDog contacts the player
		local playerBoundX = player.img:getWidth() * player.scale
		local playerBoundY = player.img:getHeight() * player.scale
		local enemyBoundX = EvilDogs.instances[i].image:getWidth() * EvilDogs.instances[i].scale
		local enemyBoundY = EvilDogs.instances[i].image:getHeight() * EvilDogs.instances[i].scale

		if math.abs(playerX - v.x) < playerBoundX then
			if math.abs(playerY - v.y) < playerBoundY then
				table.remove(EvilDogs.instances, i)
				if player.health == 1 then
					lost = true
				else
					player.health = player.health - 1
				end
			end
		end
	end

	--Spawns go up over time
	local randomOne = 0
	if 25 - timer.time > 0 then
		randomOne = love.math.random(0, 25 - timer.time * 0.15)
	end
	local randomTwo = love.math.random(0, 4)
	if randomOne == 0 and randomTwo == 0 then
		spawn()
	end
end

--Draws each of EvilDog
function EvilDogs.draw()
	for _, v in ipairs(EvilDogs.instances) do
		love.graphics.draw(v.image, v.x, v.y, 0, v.scale, v.scale, v.image:getHeight() / 2, v.image:getHeight() / 2)
	end
end

return EvilDogs

