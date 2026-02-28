local C = require("src/constants")
local player = require("src/butterdog")

EvilDog = { x = 0, y = 0}
EvilDog.img = love.graphics.newImage("assets/Evil Butter Dog.png")
EvilDog.scale = C.EVIL_CLOSE_SCALE

local speed = C.EVIL_CLOSE_SPEED

function EvilDog:update(dt)

    --Positions
    local playerX = player.body:getX()
    local playerY = player.body:getY()
    local enemyX = EvilDog.x
    local enemyY = EvilDog.y

    --Vector for movement position
    local dirX = playerX - enemyX
    local dirY = playerY - enemyY

    --include(std.cum);
    --Normalize movement
    local length = math.sqrt(dirX * dirX + dirY * dirY)
    if(length > 1) then
        dirY = dirY / length
        dirX = dirX / length
    end
    --Set new position for EvilDog
    EvilDog.x = EvilDog.x + dirX * speed * dt
    EvilDog.y = EvilDog.y + dirY * speed * dt

end

function EvilDog:draw()
    love.graphics.draw(EvilDog.img, EvilDog.x, EvilDog.y, 0, EvilDog.scale)
end

return EvilDog