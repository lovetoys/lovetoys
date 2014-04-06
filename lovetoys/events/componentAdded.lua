ComponentAdded = class("ComponentAdded")

function ComponentAdded:__init(entity, component)
    self.entity = entity
    self.component = component
end

