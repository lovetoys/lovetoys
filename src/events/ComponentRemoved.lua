local ComponentRemoved = require('src.namespace').class("ComponentRemoved")

function ComponentRemoved:initialize(entity, component)
    self.entity = entity
    self.component = component
end

return ComponentRemoved
