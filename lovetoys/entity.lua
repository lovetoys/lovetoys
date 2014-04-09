Entity = class("Entity")

function Entity:__init()
    self.components = {}
    self.eventManager = nil
end

-- Sets the entities component of this type to the given component.
-- An entity can only have one Component of each type.
function Entity:add(component)
    local isNew = true
    if self.components[component.__name] then isNew = false end

    self.components[component.__name] = component

    if self.eventManager and isNew then
        self.eventManager:fireEvent(ComponentAdded(self, component.__name))
    end
end

-- Removes a component from the entity.
function Entity:remove(name)
    if self.components[name] then
        self.components[name] = nil
    end
    if self.eventManager then
        self.eventManager:fireEvent(ComponentRemoved(self, name))
    end
end

function Entity:get(name)
    return self.components[name]
end

function Entity:getComponents()
    return self.components
end

