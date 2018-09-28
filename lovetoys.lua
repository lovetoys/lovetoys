-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local lovetoys = require(folderOfThisFile .. "init")

print('require(\'lovetoys.lovetoys\') is deprecated. Use require(\'lovetoys\') instead.')

return lovetoys
