local ok, C = pcall(require, "src/constants")
if not ok then C = {} end

local Bullets = {}
Bullets.instances = {}

local bulletImg = love.graphics.newImage("assets/buttlet.png")

local BS = {
  speed = C.BULLET_SPEED or 900,
  w = C.BULLET_W or bulletImg:getWidth(),
  h = C.BULLET_H or bulletImg:getHeight(),
  ttl = C.BULLET_TTL or 2.5,
  scale = C.BULLET_SCALE or 0.5
}

local function aabbIntersect(ax, ay, aw, ah, bx, by, bw, bh)
  return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

function Bullets.spawn(x, y, dirX, dirY)
  local angle = math.atan2(dirY, dirX)
  local b = {
    x = x,
    y = y,
    vx = dirX * BS.speed,
    vy = dirY * BS.speed,
    w = bulletImg:getWidth() * BS.scale,
    h = bulletImg:getHeight() * BS.scale,
    scale = BS.scale,
    angle = angle,
    ttl = BS.ttl
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

    if b.ttl <= 0
        or b.x < -200 or b.x > (C.WINDOW_WIDTH or 1600) + 200
        or b.y < -200 or b.y > (C.WINDOW_HEIGHT or 900) + 200 then
      table.remove(Bullets.instances, i)
    else
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
    end
  end
end

function Bullets.draw()
  love.graphics.push()
  love.graphics.setColor(1, 1, 1)
  for _, b in ipairs(Bullets.instances) do
    love.graphics.draw(bulletImg, b.x, b.y, b.angle, b.scale, b.scale, bulletImg:getWidth() / 2, bulletImg:getHeight() / 2)
  end
  love.graphics.pop()
end

return Bullets
