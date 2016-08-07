local lovetoys = require('src.namespace')
local System = lovetoys.class("System")

function System:initialize()
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

    if self.onAddEntity then self:onAddEntity(entity) end
end

function System:removeEntity(entity, component)
    -- Get the first element and check .class.name == 'Entity'
    -- In case it is an Entity, we know that this System doesn't have multiple
    -- Requirements. Otherwise we remove the Entity from each category.
    local firstElement = lovetoys.util.firstElement(self.targets)
    if firstElement then
        if firstElement.class and firstElement.class.name == 'Entity' then
            self.targets[entity.id] = nil
        else
            -- Removing entities from their respective category target list.
            for index, _ in pairs(self.targets) do
                self.targets[index][entity.id] = nil
            end
        end
    end
end

function System:componentRemoved(entity, component)
    -- Get the first element and check .class.name == 'Entity'.
    -- In case a System has multiple requirements we need to check for
    -- each requirement category if the entity has to be removed.
    local firstElement = lovetoys.util.firstElement(self.targets)
    if firstElement then
        if firstElement.class and firstElement.class.name == 'Entity' then
            self.targets[entity.id] = nil
        else
            -- Removing entities from their respective category target list.
            for index, _ in pairs(self.targets) do
                for _, req in pairs(self:requires()[index]) do
                    if req == component then
                        self.targets[index][entity.id] = nil
                        break
                    end
                end
            end
        end
    end
end

function System:pickRequiredComponents(entity)
    local components = {}
    local requirements = self:requires()

    if not requirements[1] then
    elseif type(requirements[1]) == "string" then
        for _, componentName in pairs(requirements) do
            table.insert(components, entity:get(componentName))
        end
    elseif type(requirements[1]) == "table" then
        lovetoys.debug("Error: :pickRequiredComponents() is not supported for systems with multiple component constellations")
    end
    return unpack(components)
end

return System
