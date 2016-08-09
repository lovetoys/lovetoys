-- Collection of utilities for handling Components
local Component = {}

-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

Component.all = {}

-- Create a Component class with the specified name and fields
-- which will automatically get a constructor accepting the fields as arguments
function Component.create(name, fields, defaults)
    local component = require(folderOfThisFile .. 'namespace').class(name)

    if fields then
        defaults = defaults or {}
        component.initialize = function(self, ...)
            local args = {...}
            for index, field in ipairs(fields) do
                self[field] = args[index] or defaults[field]
            end
        end
    end

    Component.register(component)

    return component
end

-- Register a Component to make it available to Component.load
function Component.register(componentClass)
    Component.all[componentClass.name] = componentClass
end

-- Load multiple components and populate the calling functions namespace with them
-- This should only be called from the top level of a file!
function Component.load(names)
    local components = {}

    for _, name in pairs(names) do
        components[#components+1] = Component.all[name]
    end
    return unpack(components)
end

return Component
