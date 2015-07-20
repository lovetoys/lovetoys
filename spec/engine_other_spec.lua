-- luacheck: globals describe setup before_each it
local class = require('middleclass')
local Component = require('Component')
local Engine = require('Engine')
local Entity = require('Entity')

describe('Engine', function()
    local Component1, Component2
    local component1
    local entity
    local engine

    setup(function()
        Component1 = class('Component1', Component)
        Component1.number = 1
        Component2 = class('Component2', Component)
        Component2.number = 2
    end)

    before_each(function()
        component1 = Component1()
        entity = Entity()

        engine = Engine()
    end)

    it(':addInitializer() adds Initializer', function()
        local init = function(_) end
        engine:addInitializer('Component1', init)
        assert.are.equal(engine.initializer['Component1'], init)
    end)

    it(':removeInitializer() removes Initializer', function()
        local init = function(_) end
        engine:addInitializer('Component1', init)
        assert.are.equal(engine.initializer['Component1'], init)

        engine:removeInitializer('Component1')
        assert.are_not.equal(engine.initializer['Component1'], init)
    end)

    it('Executes initializer on new Entity', function()
        local initializing = function(e)
            e:get('Component1').number = 12
        end
        engine:addInitializer('Component1', initializing)
        entity:add(component1)
        engine:addEntity(entity)
        assert.are.equal(entity:get('Component1').number, 12)
    end)

end)
