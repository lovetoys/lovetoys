local lovetoys = require('')
lovetoys.initialize()

describe('Component', function()
    it(':create with defaults creates a Component with default values', function()
        local c = lovetoys.Component.create('TestComponent',
          {'defaultField', 'emptyField'},
          {defaultField = 'defaultValue'})

        local instance = c()
        assert.are.equal(instance.defaultField, 'defaultValue')
        assert.is_nil(instance.emptyField)
    end)

    it(':load returns the specified components', function()
        local c1 = lovetoys.Component.create('TestComponent1')
        local c2 = lovetoys.class('TestComponent2')
        lovetoys.Component.register(c2)
        local c3 = lovetoys.class('TestComponent3')

        local loaded1, loaded2, loaded3 = lovetoys.Component.load({
            'TestComponent1', 'TestComponent2', 'TestComponent3'
        })

        assert.are.equal(loaded1, c1)
        assert.are.equal(loaded2, c2)
        assert.is_nil(loaded3)
    end)
end)
