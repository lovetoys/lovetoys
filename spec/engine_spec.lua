require 'lovetoys'

describe('Engine', function()
    local TestSystem, Component1, Component2
    local entity, entity2
    local testSystem, engine

    setup(
    function()
        TestSystem = class('TestSystem', System)
        function TestSystem:requires()
            return {'Component1'}
        end
        Component1 = class('Component1')
        Component2 = class('Component2')
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

    it(':addEntity() gives entity an id', function()
        engine:addEntity(entity)
        assert.are.equal(entity.id, 1)
    end)

    it(':addEntity() sets self.rootEntity as parent', function()
        engine:addEntity(entity)
        assert.are.equal(engine.rootEntity, entity.parent)
        assert.are.equal(engine.rootEntity.children[1], entity)
    end)

    it(':addEntity() sets self.rootEntity as parent', function()
        engine:addEntity(entity)
        assert.are.equal(engine.rootEntity, entity.parent)
    end)

    it(':addEntity() adds entity to componentlist', function()
        entity:add(Component1())
        engine:addEntity(entity)
        assert.are.equal(engine:getEntitiesWithComponent('Component1')[1], entity)
    end)

    it(':addEntity() adds entity to system, before system is added', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(testSystem)
        assert.are.equal(testSystem.targets[1], entity)
    end)

    it(':addEntity() adds entity to system, after system is added', function()
        engine:addSystem(testSystem)
        entity:add(Component1())
        engine:addEntity(entity)
        assert.are.equal(testSystem.targets[1], entity)
    end)

    it(':addEntity() handles multiple requirement lists', function()
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
