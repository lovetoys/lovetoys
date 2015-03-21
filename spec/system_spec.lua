require 'lovetoys'

describe('System', function()
    local TestSystem
    local entity, entity1, entity2
    local testSystem, engine

    setup(
    function()
        TestSystem = class('TestSystem', System)
        function TestSystem:requires()
            return {ComponentType1 = {'Component1'}, ComponentType2 = {'Component'}}
        end
    end
    )

    before_each(
    function()
        entity = Entity()
        entity.id = 1
        entity1 = Entity()
        entity1.id = 1
        entity2 = Entity()
        entity2.id = 2

        testSystem = TestSystem()
        engine = Engine()
    end
    )


    it(':addEntity() adds single', function()
        testSystem:addEntity(entity)

        assert.are.equal(testSystem.targets[1], entity)
    end)

    it(':addEntity() adds entities into different categories', function()
        engine:addSystem(testSystem)

        testSystem:addEntity(entity1, 'ComponentType1')
        testSystem:addEntity(entity2, 'ComponentType2')

        assert.are.equal(testSystem.targets['ComponentType1'][1], entity1)
        assert.are.equal(testSystem.targets['ComponentType2'][2], entity2)
    end)

    it(':removeEntity() removes single', function()
        testSystem:addEntity(entity)
        assert.are.equal(testSystem.targets[1], entity)

        testSystem:removeEntity(entity)
        assert.are_not.equal(testSystem.targets[1], entity)
    end)
end)
