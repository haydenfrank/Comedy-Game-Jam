local ok, C = pcall(require, "src/constants")
if not ok then
	C = {}
end

local Bullets = {}
Bullets.instances = {}

local bulletImg = love.graphics.newImage("assets/buttlet.png")
local eggBulletImg = love.graphics.newImage("assets/egg.png")

local ES = {
	speed = 150,
	w = C.BULLET_W or eggBulletImg:getWidth(),
	h = C.BULLET_H or eggBulletImg:getHeight(),
	ttl = C.BULLET_TTL or 10,
	scale = C.BULLET_SCALE or 0.25,
}

local BS = {
	speed = C.BULLET_SPEED or 900,
	w = C.BULLET_W or bulletImg:getWidth(),
	h = C.BULLET_H or bulletImg:getHeight(),
	ttl = C.BULLET_TTL or 5.5,
	scale = C.BULLET_SCALE or 0.5,
}

local function aabbIntersect(ax, ay, aw, ah, bx, by, bw, bh)
	return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

function Bullets.spawn(x, y, dirX, dirY, friendly)
	local angle = math.atan2(dirY, dirX)
	local b = {}
	if friendly then
		b = {
			x = x,
			y = y,
			vx = dirX * BS.speed,
			vy = dirY * BS.speed,
			w = bulletImg:getWidth() * BS.scale,
			h = bulletImg:getHeight() * BS.scale,
			scale = BS.scale,
			angle = angle,
			ttl = BS.ttl,
			friendly = true,
		}
	else
		b = {
			x = x,
			y = y,
			vx = dirX * ES.speed,
			vy = dirY * ES.speed,
			w = ES.w * ES.scale,
			h = ES.h * ES.scale,
			scale = ES.scale,
			angle = angle,
			ttl = ES.ttl,
			friendly = false,
		}
	end
	table.insert(Bullets.instances, b)
end

-- enemies: array of enemy instances (tables) with x,y,image,scale
function Bullets.update(dt, enemies)
	for i = #Bullets.instances, 1, -1 do
		local b = Bullets.instances[i]
		b.x = b.x + b.vx * dt
		b.y = b.y + b.vy * dt
		b.ttl = b.ttl - dt

		if
			b.ttl <= 0
			or b.x < -200
			or b.x > (C.WINDOW_WIDTH or 1600) + 200
			or b.y < -200
			or b.y > (C.WINDOW_HEIGHT or 900) + 200
		then
			table.remove(Bullets.instances, i)
		else
			if b.friendly then
				for j = #enemies, 1, -1 do
					local e = enemies[j]
					if e and e.image then
						local ew = e.image:getWidth() * (e.scale or 1)
						local eh = e.image:getHeight() * (e.scale or 1)
						local bx = b.x - b.w / 2
						local by = b.y - b.h / 2
						if aabbIntersect(bx, by, b.w, b.h, e.x, e.y, ew, eh) then
							table.remove(enemies, j)
							table.remove(Bullets.instances, i)
							break
						end
					end
				end
			else
				-- hostile bullet: check collision with player (ButterDog)
				if ButterDog and ButterDog.body and ButterDog.img then
					local px = ButterDog.body:getX()
					local py = ButterDog.body:getY()
					local pr = math.max(
						ButterDog.img:getWidth() * ButterDog.scale,
						ButterDog.img:getHeight() * ButterDog.scale
					) / 2
					local dx = b.x - px
					local dy = b.y - py
					if dx * dx + dy * dy < pr * pr then
						if ButterDog.health == 1 then
							lost = true
						else
							ButterDog.health = ButterDog.health - 1
						end
						table.remove(Bullets.instances, i)
					end
				end
			end
		end
	end
end

function Bullets.draw()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1)
    for _, b in ipairs(Bullets.instances) do
        if b.friendly then
            love.graphics.draw(
                bulletImg,
                b.x,
                b.y,
                b.angle,
                b.scale,
                b.scale,
                bulletImg:getWidth() / 2,
                bulletImg:getHeight() / 2
            )
        else
            love.graphics.draw(
                eggBulletImg,
                b.x,
                b.y,
                b.angle,
                b.scale,
                b.scale,
                eggBulletImg:getWidth() / 2,
                eggBulletImg:getHeight() / 2
            )
        end
    end
	love.graphics.pop()
end

return Bullets
