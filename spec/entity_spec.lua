require 'lovetoys'

describe('Entity', function()
    local TestComponent, TestComponent1, TestComponent2, TestComponent3
    local entity, entity1, entity2, parent
    local testSystem, engine

    setup(
    function()
        TestComponent = class('TestComponent', Component)
        TestComponent1 = class('TestComponent1', Component)
        TestComponent2 = class('TestComponent2', Component)
        TestComponent3 = class('TestComponent3', Component)
    end
    )

    before_each(
    function()
        entity = Entity()
        entity.id = 1
        parent = Entity()
        testComponent = TestComponent()
    end
    )

    it(':add() adds a Component', function()
        entity:add(testComponent)
        assert.is_true(testComponent == entity.components[testComponent.__name])
    end)

    it(':add() doesn`t add the same Component twice', function()
        testComponent.int = 12
        entity:add(testComponent)
        assert.is_true(entity.components[testComponent.__name].int == 12)
        -- Creation of new testComponent with varying variables
        testComponent = TestComponent()
        testComponent.int = 13
        entity:add(testComponent)
        assert.is_true(entity.components[testComponent.__name].int == 12)
    end)

    it(':get() gets a Component', function()
        entity:add(testComponent)
        assert.is_true(testComponent == entity:get(testComponent.__name))
    end)

    it(':has() shows if it has a Component', function()
        entity:add(testComponent)
        assert.is_true(entity:has(testComponent.__name))
    end)

    it(':set() adds and overwrites Components', function()
        testComponent.int = 12
        entity:set(testComponent)
        assert.is_true(entity.components[testComponent.__name].int == 12)
        testComponent = TestComponent()
        testComponent.int = 13
        entity:set(testComponent)
        assert.is_true(entity.components[testComponent.__name].int == 13)
    end)

    it(':addMultiple() adds Multiple Components at once', function()
        local testComponent1, testComponent2, testComponent3 = TestComponent1(), TestComponent2(), TestComponent3()
        local componentList = {testComponent1, testComponent2, testComponent3}
        entity:addMultiple(componentList)
        assert.is_true(entity.components[testComponent1.__name] == testComponent1)
        assert.is_true(entity.components[testComponent2.__name] == testComponent2)
        assert.is_true(entity.components[testComponent3.__name] == testComponent3)
    end)

    it(':setParent() adds a Parent', function()
        entity:setParent(parent)
        assert.is_true(entity.parent == parent)
    end)
    it(':getParent() gets a Parent', function()
        entity:setParent(parent)
        assert.is_true(entity:getParent() == parent)
    end)
    it(':registerAsChild() registers as a Child', function()
        entity:setParent(parent)
        assert.is_true(entity:getParent().children[entity.id] == entity)
    end)
end)
