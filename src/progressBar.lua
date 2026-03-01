local C = require("src/constants")
local timer = require("src/timer")

--Redo Name
local barImage = love.graphics.newImage("assets/progressBar.png")
local width = 0
local elapsed = 0
local bossStart
ProgressBar = { }

function ProgressBar.update(dt)
    elapsed = timer.time
    if(elapsed < C.GAME_TIME_LENGTH) then --Sets width over time
        width = math.min(elapsed / C.GAME_TIME_LENGTH, 1) * 860
    end
    if(elapsed >= C.GAME_TIME_BOSS_START) then --If boss starts
        bossStart = true
    end
end

function ProgressBar.draw()
    love.graphics.draw(barImage)

    love.graphics.setColor(135 / 255, 151 / 255, 220 / 255) --Set bar color

    love.graphics.rectangle("fill", 370, 50, width, 40) --Draw progress bar

    love.graphics.setColor(1, 1, 1) --Reset color


end

return ProgressBar
