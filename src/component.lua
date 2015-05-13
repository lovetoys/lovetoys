-- Metaclass for Components
-- In the future, this will be used to dynamically create Component classes
-- Also has utility functions regarding Component handling
Component = class("Component")

-- TODO this should create a new Component class
function Component:__init()

end

-- Load multiple components and populate the calling functions namespace with them
-- This should only be called from the top level of a file!
function Component.load(paths)
  local env = {}
  setmetatable(env, {__index = _G})
  setfenv(2, env)

  for _,path in pairs(paths) do
    local componentName = string.match(path, "[^/]+$")
    env[componentName] = require(path)
  end
end
