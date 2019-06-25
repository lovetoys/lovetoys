local lovetoys = require('')
lovetoys.initialize({ debugging = true })

describe('Entity', function()
    local TestComponent, TestComponent1, TestComponent2, TestComponent3
    local entity, entity1, parent
    local testSystem

    setup(
    function()
        TestComponent = lovetoys.Component.create('TestComponent')
        TestComponent1 = lovetoys.Component.create('TestComponent1')
        TestComponent2 = lovetoys.Component.create('TestComponent2')
        TestComponent3 = lovetoys.Component.create('TestComponent3')
    end
    )

    before_each(
    function()
        entity = lovetoys.Entity()
        entity.id = 1
        entity1 = lovetoys.Entity()
        entity1.id = 2
        parent = lovetoys.Entity()
        testComponent = TestComponent()
        testComponent1 = TestComponent1()
        testComponent2 = TestComponent2()
        testComponent3 = TestComponent3()
    end
    )

    it(':add() adds a Component', function()
        entity:add(testComponent)
        assert.are.equal(entity.components[testComponent.class.name], testComponent)
    end)

    it(':add() doesn`t add the same Component twice', function()
        testComponent.int = 12
        entity:add(testComponent)
        assert.are.equal(entity.components[testComponent.class.name].int, 12)
        -- Creation of new testComponent with varying variables
        testComponent = TestComponent()
        testComponent.int = 13
        entity:add(testComponent)
        assert.are_not.equal(entity.components[testComponent.class.name].int, 13)
    end)

    it(':remove() removes a Component', function()
        entity:add(testComponent)
        entity:remove('TestComponent')
    end)

    it(':remove() prints debug message if Component does not exist', function()
        local debug_spy = spy.on(lovetoys, 'debug')
        entity:remove('TestComponent')
        assert.spy(debug_spy).was_called()
        lovetoys.debug:revert()
    end)

    it(':get() gets a Component', function()
        entity:add(testComponent)
        assert.are.equal(entity:get(testComponent.class.name), testComponent)
    end)

    it(':getComponents() gets all components of an entity', function()
        entity:add(testComponent)
        entity:add(testComponent1)
        components = entity:getComponents()

        local count = 0
        for _, __ in pairs(components) do
            count = count + 1
        end

        assert.True(count == 2)
    end)

    it(':has() shows if it has a Component', function()
        entity:add(testComponent)
        assert.is_true(entity:has(testComponent.class.name))
    end)

    it(':set() adds and overwrites Components', function()
        testComponent.int = 12
        entity:set(testComponent)
        assert.are.equal(entity.components[testComponent.class.name].int, 12)
        testComponent = TestComponent()
        testComponent.int = 13
        entity:set(testComponent)
        assert.are.equal(entity.components[testComponent.class.name].int, 13)
    end)

    it(':addMultiple() adds Multiple Components at once', function()
        local componentList = {testComponent1, testComponent2, testComponent3}
        entity:addMultiple(componentList)
        assert.are.equal(entity.components[testComponent1.class.name], testComponent1)
        assert.are.equal(entity.components[testComponent2.class.name], testComponent2)
        assert.are.equal(entity.components[testComponent3.class.name], testComponent3)
    end)

    it('Constructor with parrent adds a Parent', function()
        entity = lovetoys.Entity(parent)
        assert.are.equal(entity.parent, parent)
    end)

    it(':setParent() adds a Parent', function()
        entity:setParent(parent)
        assert.are.equal(entity.parent, parent)
    end)

    it(':getParent() gets a Parent', function()
        entity:setParent(parent)
        assert.are.equal(entity:getParent(), parent)
    end)

    it(':registerAsChild() registers as a Child', function()
        entity:setParent(parent)
        assert.are.equal(entity:getParent().children[entity.id], entity)
    end)
end)
