-- Getting folder that contains our src
local folderOfThisFile = (...) .. "."

local lovetoys = require(folderOfThisFile .. 'src.namespace')

function lovetoys.debug(message)
    if lovetoys.config.debug then
        print(message)
    end
end

local function populateNamespace(ns)
    -- Requiring class
    ns.class = require(lovetoys.config.middleclassPath or folderOfThisFile .. 'lib.middleclass')

    -- Requiring util functions
    ns.util = require(folderOfThisFile .. "src.util")

    -- Requiring all Events
    ns.ComponentAdded = require(folderOfThisFile .. "src.events.ComponentAdded")
    ns.ComponentRemoved = require(folderOfThisFile .. "src.events.ComponentRemoved")

    -- Requiring the lovetoys
    ns.Entity = require(folderOfThisFile .. "src.Entity")
    ns.Engine = require(folderOfThisFile .. "src.Engine")
    ns.System = require(folderOfThisFile .. "src.System")
    ns.EventManager = require(folderOfThisFile .. "src.EventManager")
    ns.Component = require(folderOfThisFile .. "src.Component")
end

function lovetoys.initialize(opts)
    if opts == nil then opts = {} end
    if not lovetoys.initialized then
        lovetoys.config = {
            debug = false,
            globals = false
        }

        for name, val in pairs(opts) do
            lovetoys.config[name] = val
        end

        populateNamespace(lovetoys)

        if lovetoys.config.globals then
            populateNamespace(_G)
        end
        lovetoys.initialized = true
    else
        print('Lovetoys is already initialized.')
    end
end

return lovetoys
