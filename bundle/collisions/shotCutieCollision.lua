require("core/class")

ShotCutieCollision = class("ShotCutieCollision")

function ShotCutieCollision:__init()
    self.component1 = "CutieComponent"
    self.component2 = "IsShot"
end

function ShotCutieCollision:action(entities)
    local entity1 = entities.entity1   
    local entity2 = entities.entity2
    entity1:getComponent("LifeComponent").life = entity1:getComponent("LifeComponent").life - entity2:getComponent("DamageComponent").damage
    entity2:addComponent(DestroyComponent())
end