-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

path = {}
for i in string.gmatch(folderOfThisFile, '.[^.]*') do
    table.insert(path, i)
end
table.remove(path, #path)
table.remove(path, #path)
folderOfThisFile = table.concat(path)

local ComponentAdded = require(folderOfThisFile .. '.namespace').class("ComponentAdded")

function ComponentAdded:initialize(entity, component)
    self.entity = entity
    self.component = component
end

return ComponentAdded
