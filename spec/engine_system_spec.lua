require 'lovetoys'

describe('Engine', function()
    local UpdateSystem, DrawSystem, TestSystem2, Component1, Component2
    local entity, entity2, entity3
    local testSystem, engine

    setup(
    function()
        UpdateSystem = class('UpdateSystem', System)
        function UpdateSystem:requires()
            return {'Component1'}
        end
        function UpdateSystem:update()
            for _, entity in pairs(self.targets) do
                entity:get('Component1').number = entity:get('Component1').number + 5
            end
        end

        DrawSystem = class('DrawSystem', System)
        function DrawSystem:requires()
            return {'Component1'}
        end

        function DrawSystem:draw()
            for _, entity in pairs(self.targets) do
                entity:get('Component1').number = entity:get('Component1').number + 10
            end
        end

        TestSystem2 = class('TestSystem2', System)
        function TestSystem2:requires()
            return {name1 = {'Component1'}, name2 = {'Component2'}}
        end

        Component1 = class('Component1')
        Component1.number = 1
        Component2 = class('Component2')
        Component2.number = 2
    end
    )

    before_each(
    function()
        entity = Entity()
        entity2 = Entity()
        entity3 = Entity()

        updateSystem = UpdateSystem()
        drawSystem = DrawSystem()
        testSystem2 = TestSystem2()
        engine = Engine()
    end
    )

    it(':addSystem() adds update Systems', function()
        engine:addSystem(updateSystem)
        assert.are.equal(engine.systems['update'][1], updateSystem)
    end)

    it(':addSystem() adds draw Systems', function()
        engine:addSystem(drawSystem)
        assert.are.equal(engine.systems['draw'][1], drawSystem)
    end)

end)
