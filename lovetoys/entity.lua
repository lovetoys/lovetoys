Entity = class("Entity")

function Entity:__init()
    self.components = {}
    self.manager = nil
end

-- Sets the entities component of this type to the given component.
-- An entity can only have one Component of each type.
function Entity:addComponent(component)
    self.components[component.__name] = component
    if self.manager then
        self.manager:componentAdded(self, component.__name)
    end
end

function Entity:removeComponent(name)
    if self.components[name] then
        self.components[name] = nil
    end
    if self.manager then
        self.manager:componentRemoved(self, name)
    end
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:getComponents()
    return self.components
end