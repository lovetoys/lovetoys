local ParticleUpdateSystem = class("ParticleUpdateSystem", System)

function ParticleUpdateSystem:update(dt)
    for index, entity in pairs(self.targets) do
        -- Updates Particles. If timer is below 0 the entity will be removed
        entity.components.Particle.particle:update(dt)
        if entity:get("ParticleTimerComponent") then
            entity.components.ParticleTimerComponent.emitterlife = entity.components.ParticleTimerComponent.emitterlife - dt
            if entity.components.ParticleTimerComponent.emitterlife <= 0 then
                entity.components.ParticleTimerComponent.particlelife = entity.components.ParticleTimerComponent.particlelife - dt
                if entity.components.Particle.particle:isActive() then
                    entity.components.Particle.particle:pause()
                end
                if entity.components.ParticleTimerComponent.particlelife < 0 then
                    engine:removeEntity(entity)
                end
            end
        end
    end
end

function ParticleUpdateSystem:requires(dt)
    return {"Particle"}
end

return ParticleUpdateSystem
