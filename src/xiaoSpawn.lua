local C = require("src/constants")
local timer = require("src/timer")

local Xiao = { }
local xiaoImage = love.graphics.newImage("assets/xiao-pang.png")
local animationDone = false
local animationTime = 0
local xiaoX = C.WINDOW_WIDTH
local xiaoY = C.WINDOW_HEIGHT/3
local xiaoScale = 2

function Xiao.update(dt)
    if(C.GAME_TIME_BOSS_START <= timer.time) then
        animationTime = animationTime + dt
        if(animationTime > 7) then
            animationDone = true
        end
        if(not animationDone) then
            xiaoX = xiaoX - dt * 60
        end
    end

end

function Xiao.draw()
    if(C.GAME_TIME_BOSS_START <= timer.time) then
        love.graphics.draw(xiaoImage, xiaoX, xiaoY, 0, xiaoScale, xiaoScale)
    end
    
end

return Xiao
