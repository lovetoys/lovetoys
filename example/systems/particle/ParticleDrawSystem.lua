local ParticleDrawSystem = class("ParticleDrawSystem", System)

function ParticleDrawSystem:draw()
    for index, particle in pairs(self.targets) do
        love.graphics.draw(particle.components.Particle.particle, 0, 0)
        love.graphics.draw(particle.components.Particle.particle, -love.graphics.getWidth(), 0)
        love.graphics.draw(particle.components.Particle.particle, love.graphics.getWidth(), 0)
    end
end

function ParticleDrawSystem:requires()
    return {"Particle"}
end

return ParticleDrawSystem
