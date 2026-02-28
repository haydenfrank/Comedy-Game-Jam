local C = require("src/constants")
local player = require("src/butterdog")

EvilDog = { x = 0, y = 0}
EvilDog.img = love.graphics.newImage("assets/Evil Butter Dog.png")
EvilDog.scale = C.EVIL_CLOSE_SCALE

local speed = C.EVIL_CLOSE_SPEED

--Spawn generator
local function spawn()
    local where = love.math.random(0, 2)

    if(where == 1) then --Spawn left side
        EvilDog.x = - 50
        EvilDog.y = love.math.random(0, C.WINDOW_HEIGHT)
    elseif(where == 2) then --Spawn right side
        EvilDog.x = C.WINDOW_WIDTH + 50
        EvilDog.y = love.math.random(0, C.WINDOW_HEIGHT)    
    elseif(where == 3) then --Spawn up
        EvilDog.x = love.math.random(0, C.WINDOW_WIDTH)
        EvilDog.y = -50
    else --Spawn down
        EvilDog.x = love.math.random(0, C.WINDOW_WIDTH)
        EvilDog.y = C.WINDOW_HEIGHT + 50
    end

    function EvilDog:draw()
    love.graphics.draw(EvilDog.img, EvilDog.x, EvilDog.y, 0, EvilDog.scale)
    --love.graphics.print(where, 100, 0, 0, 1)
end

end



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

    spawn()

end

return EvilDog