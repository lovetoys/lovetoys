ComponentAdded = class("ComponentAdded")

function ComponentAdded:initialize(entity, component)
    self.entity = entity
    self.component = component
end

