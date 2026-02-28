local C = require("src/constants")

math.randomseed(os.time())
local windows = { instances = {} }

local frame = love.graphics.newImage("assets/pop-up-window.png")
local pressedFrame = love.graphics.newImage("assets/pop-up-window-pressed.png")

local videoFiles = {}
local files = love.filesystem.getDirectoryItems("assets/gifs-videos")
for i, file in ipairs(files) do
	if file:match("%.ogv$") then
		table.insert(videoFiles, "assets/gifs-videos/" .. file)
	end
end

local function spawnPopup()
	local path = videoFiles[math.random(1, #videoFiles)]

	local vid = love.graphics.newVideo(path)
	vid:play()

	local x =
		math.random(math.floor(frame:getWidth() / 2), math.max(math.floor(C.WINDOW_WIDTH - frame:getWidth() / 2), 1))
	local y =
		math.random(math.floor(frame:getHeight() / 2), math.max(math.floor(C.WINDOW_HEIGHT - frame:getHeight() / 2), 1))

	local scaleX, scaleY = C.VIDEO_W / vid:getWidth(), C.VIDEO_H / vid:getHeight()

	local instance = {
		video = vid,
		x = x,
		y = y,
		baseW = frame:getWidth(),
		baseH = frame:getHeight(),
		vidW = vid:getWidth(),
		vidH = vid:getHeight(),
		scaleX = scaleX,
		scaleY = scaleY,
		drawW = C.VIDEO_W,
		drawH = C.VIDEO_H,
	}

	table.insert(windows.instances, instance)
end

-- spawn timer
local spawnTimer = 0
local nextSpawn = math.random() * (C.SPAWN_MAX - C.SPAWN_MIN) + C.SPAWN_MIN

function windows.update(dt)
	for i = #windows.instances, 1, -1 do
		local v = windows.instances[i]
		if v.video and v.video.update then
			v.video:update(dt)
		end

		if not v.video:isPlaying() then
			v.video:seek(0)
			v.video:play()
		end
	end

	spawnTimer = spawnTimer + dt
	if spawnTimer >= nextSpawn then
		spawnPopup()
		spawnTimer = 0
		nextSpawn = math.random() * (C.SPAWN_MAX - C.SPAWN_MIN) + C.SPAWN_MIN
	end
end

function windows.draw()
	for _, v in ipairs(windows.instances) do
		local x, y
		x, y = v.x, v.y
		local fw, fh = v.baseW, v.baseH

		local imgX, imgY = x - fw / 2, y - fh / 2
		local mx, my = love.mouse.getPosition()
		local closeX, closeY = imgX + 320, imgY + 8
		local closeW, closeH = 376 - 320, 64 - 8 -- 56x56
		local hoveringClose = (mx >= closeX and mx <= closeX + closeW and my >= closeY and my <= closeY + closeH)

		-- draw the pop-up frame on top (switch image when hovering close)
		local frameImg = (hoveringClose and pressedFrame) and pressedFrame or frame
		love.graphics.draw(frameImg, imgX, imgY, 0)
		-- draw video scaled to the exact target size, offset 9px from top (original image space)
		if v.video then
			local drawW = v.drawW or (v.vidW * v.scaleX)
			local drawH = v.drawH or (v.vidH * v.scaleY)
			local topOffset = C.TOPOFFSET
			local videoX = x - drawW / 2 -- centered horizontally
			local videoY = (y - fh / 2) + topOffset -- 9px (scaled) from top of frame
			love.graphics.draw(v.video, videoX, videoY, 0, v.scaleX, v.scaleY)
		end
	end
end

function windows.mousepressed(mx, my, button)
	-- only handle left click
	if button ~= 1 then
		return
	end

	for i = #windows.instances, 1, -1 do
		local v = windows.instances[i]
		local x, y
		if v.body and v.body.getPosition then
			x, y = v.body:getPosition()
		else
			x, y = v.x, v.y
		end
		local fw, fh = v.baseW, v.baseH
		local imgX, imgY = x - fw / 2, y - fh / 2

		-- close button bounds (same as in draw)
		local closeX, closeY = imgX + 320, imgY + 8
		local closeW, closeH = 376 - 320, 64 - 8 -- 56x56

		if mx >= closeX and mx <= closeX + closeW and my >= closeY and my <= closeY + closeH then
			-- stop and remove this popup
			if v.video then
				if v.video.pause then
					pcall(v.video.pause, v.video)
				end
				if v.video.stop then
					pcall(v.video.stop, v.video)
				end
			end
			if v.body and v.body.destroy then
				pcall(v.body.destroy, v.body)
			end
			table.remove(windows.instances, i)
			return
		end
	end
end

return windows
