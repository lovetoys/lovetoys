require 'lovetoys'

describe('Engine', function()
    local TestSystem
    local entity, entity2
    local testSystem, engine

    setup(
    function()
        TestSystem = class('TestSystem', System)
        function TestSystem:requires()
            return {'Component1'}
        end
    end
    )

    before_each(
    function()
        entity = Entity()
        entity2 = Entity()

        testSystem = TestSystem()
        engine = Engine()
    end
    )

    it(':addEntitiy() handles multiple requirement lists', function()
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

        entity:add(Animal())

        entity2:add(Animal())
        entity2:add(Dog())

        engine:addEntity(entity)
        engine:addEntity(entity2)

        -- Check for removal from a specific target list
        -- This is needed if a single Component is removed from an entity
        testSystem:removeEntity(entity, 'ComponentType2')

        assert.are.equal(count(animalSystem.targets.animals), 2)
        assert.are.equal(count(animalSystem.targets.dogs), 1)

        entity2:remove('Dog')
        assert.are.equal(count(animalSystem.targets.animals), 2)
        assert.are.equal(count(animalSystem.targets.dogs), 0)

        entity:add(Dog())
        assert.are.equal(count(animalSystem.targets.animals), 2)
        assert.are.equal(count(animalSystem.targets.dogs), 1)
    end)
end)
