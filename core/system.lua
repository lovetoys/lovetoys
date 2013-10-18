System = class("System")

function System:__init()
    -- Liste aller Entities, die die RequiredComponents dieses Systems haben
    self.targets = {}
end

function System:update(dt) end

function System:getRequiredComponents() return {} end

function System:getEntities()
    return self.targets
end

function System:addEntity(entity)
    self.targets[entity.id] = entity
end

function System:removeEntity(entity)
    self.targets[entity.id] = nil
end