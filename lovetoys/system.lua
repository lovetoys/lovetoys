System = class("System")

function System:__init()
    -- Liste aller Entities, die die RequiredComponents dieses Systems haben
    self.targets = {}
    self.priority = 0
end

function System:update(dt) end

function System:draw() end

function System:getRequiredComponents() return {} end

function System:getEntities()
    return self.targets
end

function System:addEntity(entity, category)
    if category then
        self["targets" .. category][entity.id] = entity
    else
        self.targets[entity.id] = entity
    end
end

function System:removeEntity(entity)
    if table.firstElement(self.targets) then
        self.targets[entity.id] = nil
    else
        local tableindex = 1
        while self["targets" .. tableindex] do
            self["targets" .. tableindex][entity.id] = nil
            tableindex = tableindex+1
        end
    end
end