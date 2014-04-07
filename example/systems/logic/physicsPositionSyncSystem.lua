-- Synchronizes the Position Component with the Position of the Body Component, if an Entity has both.
PhysicsPositionSyncSystem = class("PhysicsPositionSyncSystem", System)

function PhysicsPositionSyncSystem:update(dt)
    -- Syncs the PositionComponent with the PhysicsComponent. PhysicsComponent is the primary component.
    for k, entity in pairs(self.targets) do
        entity:getComponent("PositionComponent").x = entity:getComponent("PhysicsComponent").body:getX()
        entity:getComponent("PositionComponent").y = entity:getComponent("PhysicsComponent").body:getY()
    end
end

function PhysicsPositionSyncSystem:requires()
    return {"PhysicsComponent", "PositionComponent"}
end
