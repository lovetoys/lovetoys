-- Collection of utilities for handling Components
Component = {}

Component.all = {}

-- Create a Component class with the specified name and fields
-- which will automatically get a constructor accepting the fields as arguments
function Component.create(name, fields)
	local component = class(name)

	if fields then
		for index, fieldName in ipairs(fields) do
			fields[fieldName] = fieldName
			fields[index] = nil
		end

		component.__init = function(self, ...)
			local index = 1
			for fieldName, defaultValue in pairs(fields) do
				self[fieldName] = select(index, ...) or defaultValue
				index = index + 1
			end
		end
	end

	Component.register(component)

	return component
end

-- Register a Component to make it available to Component.load
function Component.register(componentClass)
	Component.all[componentClass.__name] = componentClass
end

-- Load multiple components and populate the calling functions namespace with them
-- This should only be called from the top level of a file!
function Component.load(names)
  local env = {}
  setmetatable(env, {__index = _G})
  setfenv(2, env)

  for _,path in pairs(names) do
    env[componentName] = Component.all[componentName]
  end
end

return Component
