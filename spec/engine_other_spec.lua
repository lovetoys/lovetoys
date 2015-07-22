require 'lovetoys'

describe('Engine', function()
    local Component1, Component2
    local entity, entity2, entity3
    local engine

    setup(function()
        Component1 = Component.create('Component1')
        Component1.number = 1
        Component2 = Component.create('Component2')
        Component2.number = 2
    end)

    before_each(function()
        component1 = Component1()
        entity = Entity()
        entity2 = Entity()
        entity3 = Entity()

        engine = Engine()
    end)

    it(':addInitializer() adds Initializer', function()
        local init = function(entity) end
        engine:addInitializer('Component1', init)
        assert.are.equal(engine.initializer['Component1'], init)
    end)

    it(':removeInitializer() removes Initializer', function()
        local init = function(entity) end
        engine:addInitializer('Component1', init)
        assert.are.equal(engine.initializer['Component1'], init)

        engine:removeInitializer('Component1')
        assert.are_not.equal(engine.initializer['Component1'], init)
    end)

    it('Executes initializer on new Entity', function()
        local initializing = function(entity)
            entity:get('Component1').number = 12
        end
        engine:addInitializer('Component1', initializing)
        entity:add(component1)
        engine:addEntity(entity)
        assert.are.equal(entity:get('Component1').number, 12)
    end)

end)
