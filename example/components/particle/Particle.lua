local Particle  = Component.create("Particle")

function Particle:initialize(image, buffer)
    self.particle = love.graphics.newParticleSystem(image, buffer)
end
