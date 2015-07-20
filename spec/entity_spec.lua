-- luacheck: globals describe setup before_each it
local class = require('middleclass')
local Entity = require('Entity')
local Component = require('Component')

describe('Entity', function()
    local TestComponent, TestComponent1, TestComponent2, TestComponent3
    local entity, parent, testComponent

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

    it(':get() gets a Component', function()
        entity:add(testComponent)
        assert.are.equal(entity:get(testComponent.class.name), testComponent)
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
        local testComponent1, testComponent2, testComponent3 = TestComponent1(), TestComponent2(), TestComponent3()
        local componentList = {testComponent1, testComponent2, testComponent3}
        entity:addMultiple(componentList)
        assert.are.equal(entity.components[testComponent1.class.name], testComponent1)
        assert.are.equal(entity.components[testComponent2.class.name], testComponent2)
        assert.are.equal(entity.components[testComponent3.class.name], testComponent3)
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
