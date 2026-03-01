local C = require("src/constants")

local Bullets = {}
Bullets.instances = {}

local bulletImg = love.graphics.newImage("assets/buttlet.png")
local eggBulletImg = love.graphics.newImage("assets/egg.png")
local breadImg = love.graphics.newImage("assets/bread.png")

-- define bullet types so different visuals/speeds/scales can be used
local bulletTypes = {
    egg = {
        img = eggBulletImg,
        speed = C.EGG_BULLET_SPEED,
        w = eggBulletImg:getWidth(),
        h = eggBulletImg:getHeight(),
        scale = C.EGG_BULLET_SCALE,
    },
    butter = {
        img = bulletImg,
        speed = C.BUTTER_BULLET_SPEED,
        w = bulletImg:getWidth(),
        h = bulletImg:getHeight(),
        scale = C.BUTTER_BULLET_SCALE,
    },
    bread = {
        img = breadImg,
        speed = 325, -- a medium speed for bread
        w = breadImg:getWidth(),
        h = breadImg:getHeight(),
        -- make bread smaller when Xiao spawns it so it's less visually dominating
        scale = 0.35,
    }
}

-- slower butter variant for enemy (Xiao) shots
bulletTypes.butter_slow = {
    img = bulletImg,
    speed = 300, -- much slower than player's butter bullets
    w = bulletImg:getWidth(),
    h = bulletImg:getHeight(),
    scale = C.BUTTER_BULLET_SCALE,
}

local function aabbIntersect(ax, ay, aw, ah, bx, by, bw, bh)
	return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

-- spawn a bullet
-- signature: spawn(x, y, dirX, dirY, friendly [, kind])
-- kind: one of "egg", "butter", "bread" — defaults to egg for hostile, butter for friendly
function Bullets.spawn(x, y, dirX, dirY, friendly, kind)
    local angle = math.atan2(dirY, dirX)
    kind = kind or (friendly and "butter" or "egg")
    local t = bulletTypes[kind] or bulletTypes.egg
    local speed = t.speed or C.EGG_BULLET_SPEED
    local b = {
        x = x,
        y = y,
        vx = dirX * speed,
        vy = dirY * speed,
        w = (t.w or t.img:getWidth()) * (t.scale or 1),
        h = (t.h or t.img:getHeight()) * (t.scale or 1),
        scale = t.scale or 1,
        angle = angle,
        ttl = C.BULLET_TTL,
        friendly = friendly and true or false,
        kind = kind,
    }
    table.insert(Bullets.instances, b)
end

-- enemies: array of enemy instances (tables) with x,y,image,scale
function Bullets.update(dt, enemies)
	for i = #Bullets.instances, 1, -1 do
		local b = Bullets.instances[i]
		b.x = b.x + b.vx * dt
		b.y = b.y + b.vy * dt
		b.ttl = b.ttl - dt

		if b.ttl <= 0 or b.x < -200 or b.x > C.WINDOW_WIDTH + 200 or b.y < -200 or b.y > C.WINDOW_HEIGHT + 200 then
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
							if not C.UNKILLABLE then
								ButterDog.health = ButterDog.health - 1
							end
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
        local img = bulletImg
        if b.kind and bulletTypes[b.kind] and bulletTypes[b.kind].img then
            img = bulletTypes[b.kind].img
        else
            img = b.friendly and bulletImg or eggBulletImg
        end
        love.graphics.draw(
            img,
            b.x,
            b.y,
            b.angle,
            b.scale,
            b.scale,
            img:getWidth() / 2,
            img:getHeight() / 2
        )
    end
    love.graphics.pop()
end

return Bullets
