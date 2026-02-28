local C = require("src/constants")

local windows = { instances = {} }

local frame = love.graphics.newImage("assets/pop-up-window.png")

-- collect available video file paths
local videoFiles = {}
local files = love.filesystem.getDirectoryItems("assets/gifs-videos")
for i, file in ipairs(files) do
	if file:match("%.ogv$") then
		table.insert(videoFiles, "assets/gifs-videos/" .. file)
	end
end

-- spawn a new popup instance
local function spawnPopup()
	if #windows.instances >= C.MAX_POPUPS or #videoFiles == 0 then
		return
	end

	local path = videoFiles[math.random(1, #videoFiles)]

	-- create video safely and log errors
	local ok, vid_or_err = pcall(love.graphics.newVideo, path)
	if not ok then
		print("@LOG videos: failed to create video for", path, vid_or_err)
		return
	end
	local vid = vid_or_err
	if vid.play then
		vid:play()
	end

	local baseW, baseH = frame:getWidth(), frame:getHeight()
	local fw, fh = baseW, baseH

	-- choose a position so the full scaled frame is on-screen
	local x = math.random(math.floor(fw / 2), math.max(math.floor(C.WINDOW_WIDTH - fw / 2), 1))
	local y = math.random(math.floor(fh / 2), math.max(math.floor(C.WINDOW_HEIGHT - fh / 2), 1))

    -- position for the popup (no physics) — just overlay on screen
    local body = nil
    local shape = nil
    local fixture = nil

	-- determine video size (if supported)
	local vidW, vidH
	if vid.getWidth and vid.getHeight then
		vidW, vidH = vid:getWidth(), vid:getHeight()
	else
		vidW, vidH = baseW, baseH
	end

	-- compute scale so video becomes exactly VIDEO_W x VIDEO_H (may stretch)
	local scaleX, scaleY = C.VIDEO_W / vidW, C.VIDEO_H / vidH

    local instance = {
        video = vid,
        -- store explicit coordinates instead of a physics body
        x = x,
        y = y,
        ttl = math.random() * (C.POPUP_TTL_MAX - C.POPUP_TTL_MIN) + C.POPUP_TTL_MIN,
        baseW = baseW,
        baseH = baseH,
        vidW = vidW,
        vidH = vidH,
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
	-- tolerate being called with unexpected argument types (some callers pass tables)
	local realdt = dt
	if type(realdt) ~= "number" then
		if type(realdt) == "table" then
			realdt = realdt.dt or realdt[1] or 0
		else
			realdt = 0
		end
	end

	-- update videos and TTLs, remove expired
	for i = #windows.instances, 1, -1 do
		local v = windows.instances[i]
		if v.video and v.video.update then
			v.video:update(realdt)
		end

		v.ttl = v.ttl - realdt
		if v.ttl <= 0 then
			if v.video and v.video.pause then
				v.video:pause()
			end
			if v.body and v.body.destroy then
				v.body:destroy()
			end
			table.remove(windows.instances, i)
		end
	end

	-- handle spawning over time
	spawnTimer = spawnTimer + realdt
	if spawnTimer >= nextSpawn then
		spawnPopup()
		spawnTimer = 0
		nextSpawn = math.random() * (C.SPAWN_MAX - C.SPAWN_MIN) + C.SPAWN_MIN
	end
end

function windows.draw()
	for _, v in ipairs(windows.instances) do
		local x, y
		if v.body and v.body.getPosition then
			x, y = v.body:getPosition()
		else
			x, y = v.x, v.y
		end
		local fw, fh = v.baseW, v.baseH

		-- draw the pop-up frame on top (scaled)
		love.graphics.draw(frame, x - fw / 2, y - fh / 2, 0)
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

function windows.spawn()
	spawnPopup()
end

return windows
