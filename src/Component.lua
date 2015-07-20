-- Collection of utilities for handling Components
local class = require('middleclass')
local Component = class('Component')

Component.static.all = {}

-- Register a Component to make it available to Component.load
local function register(componentClass)
  --print('Component subclassed by '..componentClass.name)
  Component.all[componentClass.name] = componentClass
end

function Component.static:subclassed(other) -- luacheck: ignore self
  register(other)
end

function Component:initialize(fields, defaults, ...)
  if fields then
    defaults = defaults or {}
      local args = {...}
      for index, field in ipairs(fields) do
        self[field] = args[index] or defaults[field]
      end
  end
end

-- Load multiple components
function Component.static.load(names)
  local components = {}

  for _, name in pairs(names) do
    components[#components+1] = Component.all[name]
  end
  return unpack(components)
end

return Component
