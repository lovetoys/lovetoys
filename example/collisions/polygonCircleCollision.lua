PolygonCircleCollision = class("PolygonCircleCollision")

function PolygonCircleCollision:__init()
    self.component1 = "DrawablePolygonComponent"
    self.component2 = "PhysicsComponent"
end

function PolygonCircleCollision:action(entities)
    local newParticle = Entity()
    newParticle:add(ParticleComponent(particle1, 1000))

    local particle = newParticle:get("ParticleComponent").particle
    particle:setEmissionRate(300)
    particle:setSpeed(10, 10)
    particle:setSizes(0.1, 0.15)
    particle:setColors(0, 255, 0, 255, 150, 150, 0, 0)
    particle:setPosition(getMid(entities.entity1, entities.entity2))
    particle:setEmitterLifetime(0.2) -- Zeit die der Partikelstrahl anhält
    particle:setParticleLifetime(0.4, 0.4) -- setzt Lebenszeit in min-max
    particle:setOffset(0, 0) -- Punkt um den der Partikel rotiert
    particle:setRotation(0, 360) -- Der Rotationswert des Partikels bei seiner Erstellung
    particle:setDirection(0)
    particle:setSpread(360)
    particle:setRadialAcceleration(100, 100)
    particle:setLinearAcceleration(300, 300)
    particle:setAreaSpread("normal", 5, 5 )
    particle:start()

    newParticle:add(ParticleTimerComponent(0.2, 0.4))

    engine:addEntity(newParticle)
end

function getMid(entity1, entity2)
    local x1, y1 = entity1:get("PositionComponent").x, entity1:get("PositionComponent").y
    local x2, y2 = entity2:get("PositionComponent").x, entity2:get("PositionComponent").y

    return (x1 + x2)/2 , (y1 + y2)/2 
end

