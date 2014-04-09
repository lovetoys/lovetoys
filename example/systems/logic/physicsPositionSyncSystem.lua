-- Synchronizes the Position Component with the Position of the Body Component, if an Entity has both.
PhysicsPositionSyncSystem = class("PhysicsPositionSyncSystem", System)

function PhysicsPositionSyncSystem:update(dt)
    -- Syncs the PositionComponent with the PhysicsComponent. PhysicsComponent is the primary component.
    for k, entity in pairs(self.targets) do
        entity:get("PositionComponent").x = entity:get("PhysicsComponent").body:getX()
        entity:get("PositionComponent").y = entity:get("PhysicsComponent").body:getY()
    end
end

function PhysicsPositionSyncSystem:requires()
    return {"PhysicsComponent", "PositionComponent"}
end
