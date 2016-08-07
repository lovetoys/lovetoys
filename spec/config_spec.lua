local classes = {
    "Entity",
    "Engine",
    "Component",
    "EventManager",
    "System",
    "util",
    "class",
    "ComponentAdded",
    "ComponentRemoved"
}

describe('Configuration', function()
    after_each(
    function()
        local lovetoys = require('lovetoys')
        lovetoys.config = {}
        lovetoys.initialized = false
    end
    )

    it('injects classes into the global namespace if globals = true is passed', function()
        local env = {}
        setmetatable(_G, {
            __newindex = function(table, key, value)
                env[key] = value
            end,
            __index = function(table, key)
                return env[key]
            end
        })
        local lovetoys = require('lovetoys')
        lovetoys.initialize({ globals = true })

        for _, entry in ipairs(classes) do
            assert.not_nil(env[entry])
        end

        setmetatable(_G, nil)
    end)

    it('doesnt modify the global table by default', function()
        local lovetoys = require('lovetoys')
        lovetoys.initialize({})

        for _, entry in ipairs(classes) do
            assert.is_nil(_G[entry])
        end
    end)
end)
