-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local lovetoys = require(folderOfThisFile .. 'namespace')
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

    if self.onAddEntity then self:onAddEntity(entity, category) end
end

function System:removeEntity(entity, component)
    -- Get the first element and check if it's a component name
    -- In case it is an Entity, we know that this System doesn't have multiple
    -- Requirements. Otherwise we remove the Entity from each category.
    local firstGroup, _ = next(self.targets)
    if firstGroup then
        if type(firstGroup) == "string" then
            -- Removing entities from their respective category target list.
            for group, _ in pairs(self.targets) do
                self.targets[group][entity.id] = nil
                if self.onRemoveEntity then self:onRemoveEntity(entity, group) end
            end
        else
            self.targets[entity.id] = nil
            if self.onRemoveEntity then self:onRemoveEntity(entity) end
        end
    end
end

function System:componentRemoved(entity, component)
    -- Get the first element and check if it's a component name
    -- In case a System has multiple requirements we need to check for
    -- each requirement category if the entity has to be removed.
    local firstGroup, _ = next(self.targets)
    if firstGroup then
        if type(firstGroup) == "string" then
            -- Removing entities from their respective category target list.
            for group, _ in pairs(self.targets) do
                for _, req in pairs(self:requires()[group]) do
                    if req == component then
                        self.targets[group][entity.id] = nil
                        if self.onRemoveEntity then self:onRemoveEntity(entity, group) end
                        break
                    end
                end
            end
        else
            self:removeEntity(entity, component)
        end
    end
end

function System:pickRequiredComponents(entity)
    local components = {}
    local requirements = self:requires()

    if type(lovetoys.util.firstElement(requirements)) == "string" then
        for _, componentName in pairs(requirements) do
            table.insert(components, entity:get(componentName))
        end
    elseif type(lovetoys.util.firstElement(requirements)) == "table" then
        lovetoys.debug("System: :pickRequiredComponents() is not supported for systems with multiple component constellations")
        return nil
    end
    return unpack(components)
end

return System
