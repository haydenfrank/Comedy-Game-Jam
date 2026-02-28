local C = require("src/constants")

ButterNova = love.audio.newSource("assets/butternova.ogg", "static")
ButterNova:setLooping(true)
ButterNova:play()
ButterNova:setVolume(C.VOLUME)

return ButterNova
