function love.load()
	ButterDog = {}
	ButterDog.img = love.graphics.newImage("assets/butterdog.png")
	ButterDog.x = 0
	ButterDog.y = 0
	ButterNova = love.audio.newSource("assets/butternova.ogg", "static")
	ButterNova:setLooping(true)
	ButterNova:play()
	ButterNova:setVolume(0.25)
end

function love.keypressed() end

function love.update(dt)
	if love.keyboard.isDown("d") then
		ButterDog.x = ButterDog.x + 150 * dt
	end
	if love.keyboard.isDown("a") then
		ButterDog.x = ButterDog.x - 150 * dt
	end
	if love.keyboard.isDown("w") then
		ButterDog.y = ButterDog.y - 150 * dt
	end
	if love.keyboard.isDown("s") then
		ButterDog.y = ButterDog.y + 150 * dt
	end
end
function love.draw()
	love.graphics.draw(ButterDog.img, ButterDog.x, ButterDog.y)
end
