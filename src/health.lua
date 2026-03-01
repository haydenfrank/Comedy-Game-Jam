local Health = {}
local health = 3

-- Store images in a table
local healthImages = {
	love.graphics.newImage("assets/health1.png"),
	love.graphics.newImage("assets/health2.png"),
	love.graphics.newImage("assets/health3.png"),
}

function Health.update(dt)
	health = ButterDog.health
end

function Health.draw()
	love.graphics.draw(healthImages[health], 10, 10)
end

return Health
