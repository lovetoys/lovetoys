-- Synchronizes the Position Component with the Position of the Body Component, if an Entity has both.
local PhysicsPositionSyncSystem = class("PhysicsPositionSyncSystem", System)

function PhysicsPositionSyncSystem:update(dt)
    -- Syncs the Position with the Physic. Physic is the primary component.
    for k, entity in pairs(self.targets) do
        entity:get("Position").x = entity:get("Physic").body:getX()
        entity:get("Position").y = entity:get("Physic").body:getY()
    end
end

function PhysicsPositionSyncSystem:requires()
    return {"Physic", "Position"}
end

return PhysicsPositionSyncSystem
