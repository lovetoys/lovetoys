-- Getting folder that contains engine
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

lovetoyDebug = false

-- Requiring class

class = require(folderOfThisFile .. 'lib.middleclass')

-- Requiring util functions
require(folderOfThisFile .. "src.util")

-- Requiring all Events
require(folderOfThisFile .. "src.events.ComponentAdded")
require(folderOfThisFile .. "src.events.ComponentRemoved")

-- Requiring the lovetoys
require(folderOfThisFile .. "src.Entity")
require(folderOfThisFile .. "src.Engine")
require(folderOfThisFile .. "src.System")
require(folderOfThisFile .. "src.EventManager")
require(folderOfThisFile .. "src.Component")
