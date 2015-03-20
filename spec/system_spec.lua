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

        assert.is_true(testSystem.targets[1] == entity)
    end)

    it(':addEntity() adds entities into different categories', function()
        engine:addSystem(testSystem)

        testSystem:addEntity(entity1, 'ComponentType1')
        testSystem:addEntity(entity2, 'ComponentType2')

        assert.is_true(testSystem.targets['ComponentType1'][1] == entity1)
        assert.is_true(testSystem.targets['ComponentType2'][2] == entity2)
    end)

    it(':removeEntity() removes single', function()
        testSystem:addEntity(entity)
        assert.is_true(testSystem.targets[1] == entity)

        testSystem:removeEntity(entity)
        assert.is_false(testSystem.targets[1] == entity)
    end)

    it('handles multiple requirement lists', function()
        function count(t)
            local c = 0
            for _, _ in pairs(t) do
                c = c + 1
            end
            return c
        end

        local Animal, Dog = class('Animal', Component), class('Dog', Component)

        AnimalSystem = class('AnimalSystem', System)

        function AnimalSystem:update() end

        function AnimalSystem:requires()
            return {animals = {'Animal'}, dogs = {'Dog'}}
        end

        animalSystem = AnimalSystem()
        engine:addSystem(animalSystem)

        entity1:add(Animal())

        entity2:add(Animal())
        entity2:add(Dog())

        engine:addEntity(entity1)
        engine:addEntity(entity2)

        -- Check for removal from a specific target list
        -- This is needed if a single Component is removed from an entity
        testSystem:removeEntity(entity1, 'ComponentType2')

        assert.is.equal(count(animalSystem.targets.animals), 2)
        assert.is.equal(count(animalSystem.targets.dogs), 1)

        entity2:remove('Dog')
        assert.is.equal(count(animalSystem.targets.animals), 2)
        assert.is.equal(count(animalSystem.targets.dogs), 0)

        entity1:add(Dog())
        assert.is.equal(count(animalSystem.targets.animals), 2)
        assert.is.equal(count(animalSystem.targets.dogs), 1)
    end)
end)
