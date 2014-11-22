function table.firstElement(list)
    for index, value in pairs(list) do
        return value
    end
end

System = class("System")

function System:__init()
    -- Liste aller Entities, die die RequiredComponents dieses Systems haben
    self.targets = {}
    self.active = true
end

function System:requires() return {} end

function System:addEntity(entity, category)
    -- If there are multiple requirement lists, the added entities will 
    -- be added to their respetive list. 
    if category then
        self.targets[category][entity.id] = entity
    else
    -- Otherwise they'll be added to the normal self.targets list
        self.targets[entity.id] = entity
    end
end

function System:removeEntity(entity)
    if table.firstElement(self.targets) then
        if table.firstElement(self.targets).__name then
            self.targets[entity.id] = nil
        else
            -- Removing entities from their respective category target list.
            if self.targets[index] then 
                for index, value in pairs(self:requires()) do
                    self.targets[index][entity.id] = nil
                end
            end
        end
    end
end

function System:pickRequiredComponents(entity)
    local components = {}
    for i, componentName in pairs(self:requires()) do
        table.insert(components, entity:get(componentName))
    end
    return unpack(components)
end

function System:eachTarget(func)
    for k, entity in pairs(self.targets) do
        func(self, entity, self:pickRequiredComponents(entity))
    end
end

