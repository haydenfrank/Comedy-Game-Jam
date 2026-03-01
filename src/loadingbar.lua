local C = require("src/constants")
local elapsed = 0
loadingbar = {}
local loadingText = love.graphics.newImage("assets/loadingText.png")

function loadingbar.update(dt)
	if elapsed < C.LOADING_TIME then
		elapsed = elapsed + dt
	end
end

function loadingbar.draw()
	local progress = math.min(elapsed / C.LOADING_TIME, 1)

	-- Calculate current width
	local currentWidth = progress * 1120

	-- Set color
	love.graphics.setColor(135 / 255, 151 / 255, 220 / 255)

	-- Draw rectangle
	love.graphics.rectangle("fill", 240, 640, currentWidth, 100)

	-- Reset color (important in LÖVE 11+)
	love.graphics.setColor(1, 1, 1)

	love.graphics.draw(loadingText)
end

return loadingbar
