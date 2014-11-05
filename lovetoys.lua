-- Getting folder that contains engine
local folderOfThisFile = (...):match("(.-)[^%/]+$")

-- Requiring class
require(folderOfThisFile .. "src/class")

-- Requiring all Events
require(folderOfThisFile .. "src/events/componentAdded")
require(folderOfThisFile .. "src/events/componentRemoved")
require(folderOfThisFile .. "src/events/beginContact")

-- Requiring the lovetoys
require(folderOfThisFile .. "src/engine")
require(folderOfThisFile .. "src/entity")
require(folderOfThisFile .. "src/system")
require(folderOfThisFile .. "src/eventManager")
require(folderOfThisFile .. "src/collisionManager")
require(folderOfThisFile .. "src/component")

