local class = require('middleclass')
local ComponentAdded = class("ComponentAdded")

function ComponentAdded:initialize(entity, component)
    self.entity = entity
    self.component = component
end

return ComponentAdded
