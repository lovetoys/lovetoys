require("core/class")
require("core/system")

CollisionDamage = class("CollisionDamage")

function CollisionDamage:__init()
    self.component1 = "IsPlayer"
    self.component2 = "IsEnemy"
end

function CollisionDamage:action(entities)
    -- Get some info
    local e1 = entities.entity1   
    local e1XSpeed, e1YSpeed = e1:getComponent("PhysicsComponent").body:getLinearVelocity()

    local e2 = entities.entity2
    local e2XSpeed, e2YSpeed = e2:getComponent("PhysicsComponent").body:getLinearVelocity()

    local difference = distanceBetween({e1XSpeed, e1YSpeed}, {e2XSpeed, e2YSpeed})

    -- Check if there will be no damage dealt
    -- ALL HAIL MATH.ABS
    if (difference < 700) then
        return
    end

    local e1Speed = distanceBetween({0, 0}, {e1XSpeed, e1YSpeed})
    local e2Speed = distanceBetween({0, 0}, {e2XSpeed, e2YSpeed})

    -- Check who will deal the damage
    if e2Speed > e1Speed then
        self:dealDamage(e1, e2)             
    elseif e1Speed > e2Speed then
        self:dealDamage(e2, e1)
    end

    -- Blutpartikel
    blood = Entity()
    blood:addComponent(ParticleComponent(resources.images.blood1, 50, 30, 20, 10, 0.3, 0.2, 
                                            255, 0, 0, 255, 200, 0, 0, 255, 
                                            e1:getComponent("PositionComponent").x, e1:getComponent("PositionComponent").y, 0.3, 0.4, 0.5, 0, 360, 
                                            0, 360, 50, 100))
    blood:addComponent(TimeComponent(0.3, 0.5))
    engine:addEntity(blood)
    blood.components.ParticleComponent.hit:start()
end

function CollisionDamage:dealDamage(entity, entity2)
    local entityCuteness = entity2:getComponent("CutieComponent").cuteness
    local damage = math.random(0, 5 + entityCuteness)

    -- Critical hit?
    if math.random(0, 100 + 2*entityCuteness) > 100 then
        damage = damage * 3
        main.shaketimer = 0.25
    end 

    entity:getComponent("LifeComponent").life = entity:getComponent("LifeComponent").life - damage
end