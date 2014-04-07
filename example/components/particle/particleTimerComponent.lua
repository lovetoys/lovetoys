ParticleTimerComponent = class("ParticleTimerComponent", Component)

function ParticleTimerComponent:__init(particlelife, emitterlife)
    self.particlelife = particlelife + 0.2
    self.emitterlife = emitterlife
end