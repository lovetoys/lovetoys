local ComponentAdded = require('src.namespace').class("ComponentAdded")

function ComponentAdded:initialize(entity, component)
    self.entity = entity
    self.component = component
end

return ComponentAdded
