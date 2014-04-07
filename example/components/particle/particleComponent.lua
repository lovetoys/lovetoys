ParticleComponent = class("ParticleComponent")

function ParticleComponent:__init(image, buffer)
    self.particle = love.graphics.newParticleSystem(image, buffer)
end