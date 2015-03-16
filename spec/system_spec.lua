require 'lovetoys'

describe('System', function()
    describe(':addEntity()', function()
        it('adds single', function()
            local TestSystem = class('TestSystem', System)
            entity = Entity()
            entity.id = 2
            testSystem = TestSystem()
            testSystem:addEntity(entity)

            assert.is_true(testSystem.targets[2] == entity)
        end)

        it('adds entities into different categories', function()
            local TestSystem = class('TestSystem', System)
            entity1 = Entity()
            entity2.id = 1
            entity2 = Entity()
            entity2.id = 2
            testSystem = TestSystem()
            testSystem:addEntity(entity1, 'ComponentType1')
            testSystem:addEntity(entity2, 'ComponentType2')

            assert.is_true(testSystem.targets['ComponentType1'][1] == entity1)
            assert.is_true(testSystem.targets['ComponentType2'][2] == entity2)
        end)
    end)
    describe(':removeEntity()', function()
        it('removes single', function()
            local TestSystem = class('TestSystem', System)
            entity = Entity()
            entity.id = 2
            testSystem = TestSystem()
            testSystem:addEntity(entity)

            assert.is_true(testSystem.targets[2] == entity)

            testSystem:removeEntity(entity)

            assert.is_false(testSystem.targets[2] == entity)
        end)

        it('removes from different constellations', function()

            local TestSystem = class('TestSystem', System)
            function TestSystem:update() end
            function TestSystem:requires()
              return {constellation1 = {'ComponentType1'}, constellation2 = {'ComponentType2'}}
            end

            local ComponentType1 = class('ComponentType1', Component)
            local ComponentType2 = class('ComponentType2', Component)

            local testSystem = TestSystem()
            local entity1, entity2 = Entity(), Entity()
            entity1.id = 1
            entity2.id = 2

            entity1:add(ComponentType1())
            entity1:add(ComponentType2())

            entity2:add(ComponentType2())

            testSystem:addEntity(entity1, 'constellation1')
            testSystem:addEntity(entity1, 'constellation2')
            testSystem:addEntity(entity2, 'constellation2')

            assert.is_true(testSystem.targets['constellation1'][1] == entity1)
            assert.is_true(testSystem.targets['constellation2'][1] == entity1)
            assert.is_true(testSystem.targets['constellation2'][2] == entity2)

            -- Check for removal from a specific target list
            -- This is needed if a single Component is removed from an entity
            testSystem:removeEntity(entity1, 'ComponentType2')

            assert.is_true(testSystem.targets['constellation1'][1] == entity1)
            assert.is_false(testSystem.targets['constellation2'][1] == entity1)
            assert.is_true(testSystem.targets['constellation2'][2] == entity2)

            testSystem:removeEntity(entity1)
            testSystem:removeEntity(entity2)

            assert.is_false(testSystem.targets['constellation1'][1] == entity1)
            assert.is_false(testSystem.targets['constellation2'][1] == entity1)
            assert.is_false(testSystem.targets['constellation2'][2] == entity2)
        end)
    end)
end)
