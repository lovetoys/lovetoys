local class = require('middleclass')
local ComponentRemoved = class("ComponentRemoved")

function ComponentRemoved:initialize(entity, component)
    self.entity = entity
    self.component = component
end

return ComponentRemoved
