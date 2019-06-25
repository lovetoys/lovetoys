local lovetoys = require('')
lovetoys.initialize()

describe('Engine', function()
    local UpdateSystem, DrawSystem, MultiSystem, Component1, Component2
    local entity, entity2, entity3
    local testSystem, engine

    setup(function()
        -- Creates a Update System
        UpdateSystem = lovetoys.class('UpdateSystem', lovetoys.System)
        function UpdateSystem:initialize()
            lovetoys.System.initialize(self)
            self.entitiesAdded = 0
        end
        function UpdateSystem:requires()
            return {'Component1'}
        end
        function UpdateSystem:update()
            for _, entity in pairs(self.targets) do
                entity:get('Component1').number = entity:get('Component1').number + 5
            end
        end

        function UpdateSystem:onAddEntity()
            self.entitiesAdded = self.entitiesAdded + 1
        end

        -- Creates a Draw System
        DrawSystem = lovetoys.class('DrawSystem', lovetoys.System)
        function DrawSystem:requires()
            return {'Component1'}
        end

        function DrawSystem:draw()
            for _, entity in pairs(self.targets) do
                entity:get('Component1').number = entity:get('Component1').number + 10
            end
        end

        -- Creates a system with update and draw function
        BothSystem = lovetoys.class('BothSystem', lovetoys.System)
        function BothSystem:requires()
            return {'Component1', 'Component2'}
        end
        function BothSystem:update()
            for _, entity in pairs(self.targets) do
                entity:get('Component1').number = entity:get('Component1').number + 5
            end
        end
        function BothSystem:draw() end

        -- Creates a System with multiple requirements
        MultiSystem = lovetoys.class('MultiSystem', lovetoys.System)
        function MultiSystem:requires()
            return {name1 = {'Component1'}, name2 = {'Component2'}}
        end

        Component1 = lovetoys.Component.create('Component1')
        Component1.number = 1
        Component2 = lovetoys.Component.create('Component2')
        Component2.number = 2
    end)

    before_each(function()
        entity = lovetoys.Entity()
        entity2 = lovetoys.Entity()
        entity3 = lovetoys.Entity()

        updateSystem = UpdateSystem()
        drawSystem = DrawSystem()
        bothSystem = BothSystem()
        multiSystem2 = MultiSystem()
        engine = lovetoys.Engine()
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

    it('Calling system status functions on not existing systems throws debug message.', function()
        -- Mock lovetoys debug function
        local debug_spy = spy.on(lovetoys, 'debug')

        engine:startSystem('weirdstufflol')
        -- Assert that the debug function has been called
        -- and clear spy call history
        assert.spy(debug_spy).was_called()
        lovetoys.debug:clear()

        engine:toggleSystem('weirdstufflol')
        assert.spy(debug_spy).was_called()
        lovetoys.debug:clear()

        engine:stopSystem('weirdstufflol')
        assert.spy(debug_spy).was_called()
        lovetoys.debug:clear()

        lovetoys.debug:revert()
    end)


    it('calls UpdateSystem:onComponentAdded when a component is added to UpdateSystem', function()
        assert.are.equal(updateSystem.entitiesAdded, 0)

        entity:add(Component1())
        engine:addSystem(updateSystem)
        engine:addEntity(entity)

        assert.are.equal(updateSystem.entitiesAdded, 1)
    end)

    it(':addSystem(system, "derp") fails', function()
        local debug_spy = spy.on(lovetoys, 'debug')

        engine:addSystem(drawSystem, 'derp')
        assert.is_nil(engine.systemRegistry['DrawSystem'])

        assert.spy(debug_spy).was_called()
        lovetoys.debug:revert()
    end)

    it('refuses to add two instances of the same system', function()
        local debug_spy = spy.on(lovetoys, 'debug')

        engine:addSystem(DrawSystem())
        engine:addSystem(DrawSystem())

        assert.spy(debug_spy).was_called()
        lovetoys.debug:clear()

        engine:addSystem(BothSystem(), 'update')
        engine:addSystem(BothSystem(), 'draw')

        assert.spy(debug_spy).was_called()
        lovetoys.debug:revert()
    end)
end)
