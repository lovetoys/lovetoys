-- Collection of utilities for handling Components
Component = {}

Component.all = {}

-- Create a Component class with the specified name and fields
-- which will automatically get a constructor accepting the fields as arguments
function Component.create(name, fields)
	local component = class(name)

	if fields then
		for index, field in ipairs(fields) do
			if type(field) == "table" then
				-- Quick hack to find the first table element
				for fieldName, defaultValue in pairs(field) do
					fields[index] = {fieldName, defaultValue}
				end
			elseif type(field) == "string" then
				fields[index] = {field, nil}
			end
		end

		component.__init = function(self, ...)
			for index, field in ipairs(fields) do
				self[field[1]] = select(index, ...) or field[2]
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

  for _, name in pairs(names) do
    env[name] = Component.all[name]
  end
end

return Component
