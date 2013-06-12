BounceCollision = class("BounceCollision")

function BounceCollision:__init()
    self.component1 = "DrawablePolygonComponent"
    self.component2 = "CutieComponent"
end

function BounceCollision:action(entities)
    local cutie = entities.entity2

    local cutiexv, cutieyv = cutie:getComponent("PhysicsComponent").body:getLinearVelocity()
    cutie:getComponent("PhysicsComponent").body:setLinearVelocity(cutiexv, -200)
    if cutie:getComponent("IsPlayer") then
        cutie:getComponent("IsPlayer").jumpcount = 2
    end
end

