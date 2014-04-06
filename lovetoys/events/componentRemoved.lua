ComponentRemoved = class("ComponentRemoved")

function ComponentRemoved:__init(entity, component)
    self.entity = entity
    self.component = component
end

