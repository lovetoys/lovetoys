Entity = class("Entity")

function Entity:__init()
    self.components = {}
end

-- Sets the entities component of this type to the given component.
-- An entity can only have one Component of each type.
function Entity:addComponent(component)
    self.components[component.__name] = component
end

function Entity:removeComponent(name)
    if self.components[name] then
        self.components[name] = nil
    end
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:getComponents()
    return self.components
end