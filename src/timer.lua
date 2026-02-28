local Timer = { time = 0 }

function Timer:update(dt)
    self.time = self.time + dt
end

function Timer:reset()
    self.time = 0
end

function Timer:get()
    return self.time
end

return Timer
