require("core/class")

ShotWallCollision = class("ShotWallCollision")

function ShotWallCollision:__init()
    self.component1 = "DrawablePolygonComponent"
    self.component2 = "IsShot"
end

function ShotWallCollision:action(entities)
    local entity1 = entities.entity1   
    local entity2 = entities.entity2
    entity2:addComponent(DestroyComponent())
end

