-- luacheck: globals describe setup before_each it assert
local class = require('middleclass')
local Component = require('Component')
local Engine = require('Engine')
local Entity = require('Entity')
local System = require('System')

describe('Engine', function()
    local UpdateSystem, DrawSystem, MultiSystem, BothSystem, Component1, Component2
    local updateSystem, drawSystem, multiSystem2, bothSystem
    local entity
    local engine

    setup(function()
        -- Creates a Update System
        UpdateSystem = class('UpdateSystem', System)
        function UpdateSystem:requires()
            return {'Component1'}
        end
        function UpdateSystem:update()
            for _, e in pairs(self.targets) do
                e:get('Component1').number = e:get('Component1').number + 5
            end
        end

        -- Creates a Draw System
        DrawSystem = class('DrawSystem', System)
        function DrawSystem:requires()
            return {'Component1'}
        end

        function DrawSystem:draw()
            for _, e in pairs(self.targets) do
                e:get('Component1').number = e:get('Component1').number + 10
            end
        end

        -- Creates a system with update and draw function
        BothSystem = class('BothSystem', System)
        function BothSystem:requires()
            return {'Component1', 'Component2'}
        end
        function BothSystem:update()
            for _, e in pairs(self.targets) do
                e:get('Component1').number = e:get('Component1').number + 5
            end
        end
        function BothSystem:draw() end

        -- Creates a System with multiple requirements
        MultiSystem = class('MultiSystem', System)
        function MultiSystem:requires()
            return {name1 = {'Component1'}, name2 = {'Component2'}}
        end

        Component1 = class('Component1', Component)
        Component1.number = 1
        Component2 = class('Component2', Component)
        Component2.number = 2
    end)

    before_each(function()
        entity = Entity()

        updateSystem = UpdateSystem()
        drawSystem = DrawSystem()
        bothSystem = BothSystem()
        multiSystem2 = MultiSystem()
        engine = Engine()
    end)

    it(':addSystem() adds update Systems', function()
        engine:addSystem(updateSystem)
        assert.are.equal(engine.systems['update'][1], updateSystem)
    end)

    it(':addSystem() adds System to systemRegistry', function()
        engine:addSystem(updateSystem)
        assert.are.equal(engine.systemRegistry[updateSystem.class.name], updateSystem)
    end)

    it(':addSystem() doesn`t add same system type twice', function()
        engine:addSystem(updateSystem)
        local newUpdateSystem = UpdateSystem()
        engine:addSystem(newUpdateSystem)
        assert.are.equal(engine.systems['update'][1], updateSystem)
        assert.are.equal(engine.systemRegistry[updateSystem.class.name], updateSystem)
    end)

    it(':addSystem() adds draw Systems', function()
        engine:addSystem(drawSystem)
        assert.are.equal(engine.systems['draw'][1], drawSystem)
    end)

    it(':addSystem() doesn`t add Systems with both, but does, if specified with type', function()
        engine:addSystem(bothSystem)
        assert.are_not.equal(engine.systems['draw'][1], bothSystem)
        assert.are_not.equal(engine.systems['update'][1], bothSystem)

        engine:addSystem(bothSystem, 'draw')
        engine:addSystem(bothSystem, 'update')
        assert.are.equal(engine.systems['draw'][1], bothSystem)
        assert.are.equal(engine.systems['update'][1], bothSystem)
    end)

    it(':addSystem() adds BothSystem to singleRequirements, if specified with type', function()
        engine:addSystem(bothSystem)
        assert.are_not.equal(type(engine.singleRequirements['Component1']), 'table')
        assert.are_not.equal(type(engine.singleRequirements['Component2']), 'table')

        engine:addSystem(bothSystem, 'draw')
        assert.are.equal(engine.singleRequirements['Component1'][1], bothSystem)
        assert.are_not.equal(type(engine.singleRequirements['Component2']), 'table')
    end)

    it(':addSystem() adds BothSystem to singleRequirements, if specified with type', function()
        engine:addSystem(bothSystem)
        assert.are_not.equal(type(engine.allRequirements['Component1']), 'table')
        assert.are_not.equal(type(engine.allRequirements['Component2']), 'table')

        engine:addSystem(bothSystem, 'draw')
        assert.are.equal(engine.allRequirements['Component1'][1], bothSystem)
        assert.are.equal(engine.allRequirements['Component2'][1], bothSystem)
    end)


    it(':addSystem() doesn`t add Systems to requirement lists multiple times', function()
        engine:addSystem(bothSystem, 'draw')
        engine:addSystem(bothSystem, 'update')

        assert.are.equal(engine.singleRequirements['Component1'][1], bothSystem)
        assert.are_not.equal(engine.singleRequirements['Component1'][2], bothSystem)
        assert.are_not.equal(type(engine.singleRequirements['Component2']), 'table')

        assert.are.equal(engine.allRequirements['Component1'][1], bothSystem)
        assert.are.equal(engine.allRequirements['Component2'][1], bothSystem)
        assert.are_not.equal(engine.allRequirements['Component1'][2], bothSystem)
        assert.are_not.equal(engine.allRequirements['Component2'][2], bothSystem)
    end)

    it(':addSystem() doesn`t add Systems to system lists multiple times', function()
        engine:addSystem(bothSystem, 'draw')
        engine:addSystem(bothSystem, 'draw')

        engine:addSystem(bothSystem, 'update')
        engine:addSystem(bothSystem, 'update')

        assert.are.equal(engine.systems['draw'][1], bothSystem)
        assert.are.equal(engine.systems['update'][1], bothSystem)

        assert.are_not.equal(engine.systems['draw'][2], bothSystem)
        assert.are_not.equal(engine.systems['update'][2], bothSystem)
    end)

    it(':update() updates Systems', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(updateSystem)
        assert.are.equal(entity:get('Component1').number, 1)
        engine:update()
        assert.are.equal(entity:get('Component1').number, 6)
    end)

    it(':update() updates Systems', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(drawSystem)
        assert.are.equal(entity:get('Component1').number, 1)
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 11)
    end)

    it(':update() updates Systems', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(drawSystem)
        assert.are.equal(entity:get('Component1').number, 1)
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 11)
    end)

    it(':stop(), start(), toggle() works', function()
        entity:add(Component1())
        engine:addEntity(entity)
        engine:addSystem(drawSystem)
        assert.are.equal(entity:get('Component1').number, 1)
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 11)

        engine:stopSystem('DrawSystem')
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 11)

        engine:startSystem('DrawSystem')
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 21)

        engine:toggleSystem('DrawSystem')
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 21)

        engine:toggleSystem('DrawSystem')
        engine:draw()
        assert.are.equal(entity:get('Component1').number, 31)
    end)
end)
