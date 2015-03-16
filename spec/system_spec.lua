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

        it('handles multiple requirement lists', function()
            local engine, AnimalSystem, animalSystem, A, B

            engine = Engine()

            AnimalSystem = class('AnimalSystem', System)

            function AnimalSystem:update() end

            function AnimalSystem:requires()
              return {animals = {'Animal'}, dogs = {'Dog'}}
            end

            animalSystem = AnimalSystem()
            engine:addSystem(animalSystem)

            Animal, Dog = class('Animal', Component), class('Dog', Component)

            function count(t)
              local c = 0
              for _, _ in pairs(t) do
                c = c + 1
              end
              return c
            end
            testSystem:removeEntity(entity)
            e1:add(Animal())

            e2:add(Animal())
            e2:add(Dog())

            -- Check for removal from a specific target list
            -- This is needed if a single Component is removed from an entity
            testSystem:removeEntity(entity1, 'ComponentType2')

            assert.is.equal(count(s.targets.animals), 2)
            assert.is.equal(count(s.targets.dogs),1)

            e2:remove('Dog')
            assert.is.equal(count(s.targets.animals), 2)
            assert.is.equal(count(s.targets.dogs), 0)

            e1:add(Dog())
            assert.is.equal(count(s.targets.animals), 2)
            assert.is.equal(count(s.targets.dogs), 1)
        end)
    end)
end)
