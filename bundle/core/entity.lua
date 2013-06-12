require("core/class")

Entity = class("Entity")

function Entity:__init()
    self.components = {}
end

function Entity:addComponent(component)
    self.components[component.__name] = component
    engine:refreshEntity(self)
end

function Entity:removeComponent(name)
    if self.components[name] then
        self.components[name] = nil
    end
    engine:refreshEntity(self)
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:getComponents()
    return self.components
end