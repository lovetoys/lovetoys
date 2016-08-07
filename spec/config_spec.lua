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
    it('doesnt modify the global table if globals = false is passed', function()
        require('lovetoys')({
            globals = false
        })

        for _, entry in ipairs(classes) do
            assert.is_nil(_G[entry])
        end
    end)

    it('injects classes into the global namespace by default', function()
        require('lovetoys')()

        for _, entry in ipairs(classes) do
            assert.not_nil(_G[entry])
        end
    end)
end)
