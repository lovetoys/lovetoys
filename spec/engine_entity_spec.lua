local lovetoys = require('lovetoys')
lovetoys.initialize({ globals = true })

describe('Engine', function()
    local TestSystem, MultiSystem
    local Component1, Component2
    local entity, entity2, entity3
    local testSystem, multiSystem, engine

    setup(
    function()
        TestSystem = lovetoys.class('TestSystem', System)
        function TestSystem:requires()
            return {'Component1'}
        end

        -- Creates a System with multiple requirements
        MultiSystem = lovetoys.class('MultiSystem', System)
        function MultiSystem:requires()
            return {name1 = {'Component1'}, name2 = {'Component1', 'Component2'}}
        end

        Component1 = Component.create('Component1')
        Component2 = Component.create('Component2')
    end
    )

    before_each(
    function()
        entity = Entity()
        entity2 = Entity()
        entity3 = Entity()

        testSystem = TestSystem()
        engine = Engine()
        multiSystem = MultiSystem()
    end
    )

    it(':addEntity() gives entity an id', function()
        engine:addEntity(entity)
        assert.are.equal(entity.id, 1)
    end)

    it(':addEntity() sets self.rootEntity as parent', function()
        engine:addEntity(entity)
        assert.are.equal(engine.rootEntity, entity.parent)
    end)

    it(':addEntity() registers entity in self.rootEntity.children', function()
        engine:addEntity(entity)
        assert.are.equal(engine.rootEntity.children[1], entity)
    end)

    it(':addEntity() sets custom parent', function()
        engine:addEntity(entity)
        entity2.parent = entity
        engine:addEntity(entity2)
        assert.are.equal(entity.children[2], entity2)
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

    it(':add() adds entity to system, after Component is added to entity', function()
        engine:addEntity(entity)
        engine:addSystem(testSystem)
        entity:add(Component1())
        assert.are.equal(testSystem.targets[1], entity)
    end)

    it(':addEntity() adds entity to system, after Component is added to system', function()
        engine:addEntity(entity)
        engine:addSystem(testSystem)
        entity:add(Component1())
        assert.are.equal(testSystem.targets[1], entity)
    end)

    it(':addEntity() handles multiple requirement lists', function()
        local function count(t)
            local c = 0
            for _, _ in pairs(t) do
                c = c + 1
            end
            return c
        end

        local Animal, Dog = Component.create('Animal'), Component.create('Dog')

        local AnimalSystem = lovetoys.class('AnimalSystem', System)

        function AnimalSystem:update() end

        function AnimalSystem:requires()
            return {animals = {'Animal'}, dogs = {'Dog'}}
        end

        local animalSystem = AnimalSystem()
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

    it(':removeEntity() removes a single', function()
        engine:addEntity(entity)
        assert.are.equal(engine.rootEntity.children[1], entity)
        engine:removeEntity(entity)
        assert.are_not.equal(engine.rootEntity.children[1], entity)
    end)

    it(':removeEntity() removes entity from Parent', function()
        engine:addEntity(entity)
        assert.are.equal(engine.rootEntity.children[1], entity)
        engine:removeEntity(entity)
        assert.are_not.equal(engine.rootEntity.children[1], entity)
    end)

    it(':removeEntity() sets rootEntity as new parent/ registers as child', function()
        engine:addEntity(entity)
        entity2.parent = entity
        engine:addEntity(entity2)
        assert.are.equal(entity.children[2], entity2)
        engine:removeEntity(entity)
        assert.are.equal(engine.rootEntity.children[2], entity2)
        assert.are.equal(engine.rootEntity, entity2.parent)
    end)

    it(':removeEntity() sets rootEntity as new parent', function()
        engine:addEntity(entity)
        entity2.parent = entity
        engine:addEntity(entity2)
        assert.are.equal(entity.children[2], entity2)
        engine:removeEntity(entity)
        assert.are.equal(engine.rootEntity.children[2], entity2)
    end)

    it(':removeEntity() deletes children', function()
        engine:addEntity(entity)
        entity2.parent = entity
        engine:addEntity(entity2)
        assert.are.equal(entity.children[2], entity2)
        engine:removeEntity(entity, true)
        assert.are.equal(engine.entities[1], nil)
        assert.are.equal(engine.entities[2], nil)
    end)

    it(':removeEntity() sets custom parent', function()
        engine:addEntity(entity)
        entity2.parent = entity
        engine:addEntity(entity2)
        assert.are.equal(entity.children[2], entity2)
        engine:removeEntity(entity, false, entity3)
        assert.are.equal(entity3.children[2], entity2)
        assert.are.equal(entity3, entity2.parent)
    end)

    it(':removeEntity() removes from componentlist', function()
        entity:add(Component1())
        engine:addEntity(entity)
        assert.are.equal(engine:getEntitiesWithComponent('Component1')[1], entity)
        engine:removeEntity(entity)
        assert.are_not.equal(engine:getEntitiesWithComponent('Component1')[1], entity)
    end)

    it(':removeEntity() removes from System', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(testSystem)
        assert.are.equal(testSystem.targets[1], entity)
        engine:removeEntity(entity)
        assert.are_not.equal(testSystem.targets[1], entity)
    end)

    it(':removeEntity() unregistered entity from Engine', function()
        -- Mock lovetoys debug function
        local debug_spy = spy.on(lovetoys, 'debug')

        -- Add Component to entity and remove entity from engine
        -- before it's registered to the engine.
        entity:add(Component1())
        engine:removeEntity(entity)

        -- Assert that the debug function hast been called
        assert.spy(debug_spy).was_called()
        lovetoys.debug:clear()

        entity.id = 1
        engine:removeEntity(entity)
        assert.spy(debug_spy).was_called()

        lovetoys.debug:revert()
    end)

    it('Entity:remove() removes entity from single system target list, after removing component', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(testSystem)
        assert.are.equal(testSystem.targets[1], entity)

        entity:remove('Component1')
        assert.are_not.equal(testSystem.targets[1], entity)
    end)

    it('Entity:remove() removes entity from system, after removing component', function()
        entity:add(Component1())
        entity:add(Component2())
        engine:addEntity(entity)
        engine:addSystem(multiSystem)
        assert.are.equal(multiSystem.targets['name1'][1], entity)
        assert.are.equal(multiSystem.targets['name2'][1], entity)

        entity:remove('Component2')
        assert.are.equal(multiSystem.targets['name1'][1], entity)
        assert.True(#multiSystem.targets['name2'] == 0)
    end)

    it('Entity:remove() removes entity from system with multiple requirements', function()
        entity:add(Component1())
        entity:add(Component2())
        engine:addEntity(entity)
        engine:addSystem(multiSystem)
        assert.are.equal(multiSystem.targets['name1'][1], entity)
        assert.are.equal(multiSystem.targets['name2'][1], entity)

        engine:removeEntity(entity)
        assert.True(#multiSystem.targets['name1'] == 0)
        assert.True(#multiSystem.targets['name2'] == 0)
    end)


    it(':getRootEntity() gets rootEntity', function()
        assert.are.equal(engine:getRootEntity(), engine.rootEntity)
    end)
end)
