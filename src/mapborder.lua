local C = require("src/constants")
MapBorder = {}
MapBorder.shape =
	love.physics.newChainShape(true, 0, 0, C.WINDOW_WIDTH, 0, C.WINDOW_WIDTH, C.WINDOW_HEIGHT, 0, C.WINDOW_HEIGHT)
MapBorder.body = love.physics.newBody(World, 0, 0, "static")
MapBorder.fixture = love.physics.newFixture(MapBorder.body, MapBorder.shape)
return MapBorder
