local C = require("src/constants")

local windows = {}

local files = love.filesystem.getDirectoryItems("assets/gifs-videos")
for i, file in ipairs(files) do
	local name = file:match("(.+)%.ogv")
	if name then
		windows.videos[name] = love.graphics.newVideo("assets/videos/" .. file)
	end
end

local frame = love.graphics.newImage("assets/pop-up-window.png")

for name, video in pairs(windows.videos) do
	windows.videos[name].body = love.physics.newBody(World, 0, 0, "static")
	windows.videos[name].shape = love.physics.newRectangleShape(frame:getWidth(), frame:getHeight())
	windows.videos[name].fixture = love.physics.newFixture(windows.videos[name].body, windows.videos[name].shape)
	windows.videos[name].body:setPosition(math.random(0, C.WINDOW_WIDTH / 2), math.random(0, C.WINDOW_HEIGHT / 2))
end

return windows
