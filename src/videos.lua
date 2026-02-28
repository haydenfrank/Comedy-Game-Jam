local C = require("src/constants")

-- Configuration
local FRAME_SCALE = 4 -- draw the pop-up frame 4x its image size
local SPAWN_MIN = 1.0 -- seconds (min) between spawns
local SPAWN_MAX = 4.0 -- seconds (max) between spawns
local POPUP_TTL_MIN = 6.0 -- seconds a popup stays on screen
local POPUP_TTL_MAX = 12.0
local MAX_POPUPS = 8

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
	if #windows.instances >= MAX_POPUPS or #videoFiles == 0 then
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
	if vid.setLooping then
		vid:setLooping(true)
	end
	if vid.play then
		vid:play()
	end

	local baseW, baseH = frame:getWidth(), frame:getHeight()
	local fw, fh = baseW * FRAME_SCALE, baseH * FRAME_SCALE

	-- choose a position so the full scaled frame is on-screen
	local x = math.random(math.floor(fw / 2), math.max(math.floor(C.WINDOW_WIDTH - fw / 2), 1))
	local y = math.random(math.floor(fh / 2), math.max(math.floor(C.WINDOW_HEIGHT - fh / 2), 1))

	-- create physics body safely
	local ok2, body_or_err = pcall(love.physics.newBody, World, x, y, "static")
	if not ok2 then
		print("@LOG videos: failed to create physics body:", body_or_err)
		if vid and vid.pause then
			vid:pause()
		end
		return
	end
	local body = body_or_err
	local shape = love.physics.newRectangleShape(fw, fh)
	local fixture = love.physics.newFixture(body, shape)

	-- determine video size (if supported)
	local vidW, vidH
	if vid.getWidth and vid.getHeight then
		vidW, vidH = vid:getWidth(), vid:getHeight()
	else
		vidW, vidH = baseW, baseH
	end

	-- compute scale so video fills the scaled frame (preserve aspect by fitting)
	local scale = math.min(fw / vidW, fh / vidH)
	local scaleX, scaleY = scale, scale

	local instance = {
		video = vid,
		body = body,
		shape = shape,
		fixture = fixture,
		ttl = math.random() * (POPUP_TTL_MAX - POPUP_TTL_MIN) + POPUP_TTL_MIN,
		baseW = baseW,
		baseH = baseH,
		frameScale = FRAME_SCALE,
		vidW = vidW,
		vidH = vidH,
		scaleX = scaleX,
		scaleY = scaleY,
	}

	table.insert(windows.instances, instance)
end

-- spawn timer
local spawnTimer = 0
local nextSpawn = math.random() * (SPAWN_MAX - SPAWN_MIN) + SPAWN_MIN

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
		nextSpawn = math.random() * (SPAWN_MAX - SPAWN_MIN) + SPAWN_MIN
	end
end

function windows.draw()
	for _, v in ipairs(windows.instances) do
		local x, y = v.body:getPosition()
		local fw, fh = v.baseW * v.frameScale, v.baseH * v.frameScale

		love.graphics.draw(frame, x - fw / 2, y - fh / 2, 0, v.frameScale, v.frameScale)
		-- draw video scaled to fit inside the scaled frame, centered
		if v.video then
			local drawW = v.vidW * v.scaleX
			local drawH = v.vidH * v.scaleY
			love.graphics.draw(v.video, x - drawW / 2, y - drawH / 2, 0, v.scaleX, v.scaleY)
		end

		-- draw the pop-up frame on top (scaled)
	end
end

function windows.spawn()
	spawnPopup()
end

return windows
