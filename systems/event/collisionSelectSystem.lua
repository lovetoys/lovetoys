require("collisions/bounceCollision")
require("collisions/collisionDamage")
require("collisions/shotCutieCollision")
require("collisions/shotWallCollision")

CollisionSelectSystem = class("CollisionDetectSystem", System)

function CollisionSelectSystem:__init()
    self.conditions = {}

    local bounce = BounceCollision()
    self:addCollisionAction(bounce.component1, bounce.component2, bounce)
    local damage = CollisionDamage()
    self:addCollisionAction(damage.component1, damage.component2, damage)
    local shotcutie = ShotCutieCollision()
    self:addCollisionAction(shotcutie.component1, shotcutie.component2, shotcutie)
    local shotwall = ShotWallCollision()
    self:addCollisionAction(shotwall.component1, shotwall.component2, shotwall)
end

function CollisionSelectSystem:addCollisionAction(component1, component2, object)
    if not self.conditions[component1] then self.conditions[component1] = {} end
    self.conditions[component1][component2] = object
end

function CollisionSelectSystem:fireEvent(event)
    local e1 = event.a:getUserData()
    local e2 = event.b:getUserData()

    for k,v in pairs(e1:getComponents()) do
        for k2,val in pairs(e2:getComponents()) do
            if self.conditions[k] then
                if self.conditions[k][k2] then self.conditions[k][k2]:action({entity1=e1, entity2=e2}) end
            elseif self.conditions[k2] then
                if self.conditions[k2][k] then self.conditions[k2][k]:action({entity1=e2, entity2=e1}) end
            end
        end
    end
end