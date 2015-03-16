require 'lovetoys'

describe('Engine', function()
    describe(':addEntity()', function()
        it('handles multiple requirement lists', function()
            function table.getLength(t)
              local length = 0
              for _, _ in pairs(t) do
              	length = length + 1
              end
              return length
            end
            -- character, type1, type2, active
            local ComponentType1 = class('ComponentType1', Component)
            local ComponentType2 = class('ComponentType2', Component)

            local entity1, entity2 = Entity(), Entity()

            entity1:add(ComponentType1())
            entity1:add(ComponentType2())

            entity2:add(ComponentType1())


            local TestSystem = class('TestSystem', System)
            function TestSystem:update() end
            function TestSystem:requires()
              return {constellation1 = {'ComponentType2'}, constellation2 = {'ComponentType1'}}
            end

            local testSystem = TestSystem()

            local engine = Engine()
            engine:addSystem(testSystem)

            engine:addEntity(entity1)
            engine:addEntity(entity2)

            assert.is_true(1 == table.getLength(testSystem.targets.constellation1))
            assert.is_true(2 == table.getLength(testSystem.targets.constellation2))

            -- make entity1 non-active
            entity1:remove('ComponentType2')
            assert.is_true(0 == table.getLength(testSystem.targets.constellation1))
            assert.is_true(2 == table.getLength(testSystem.targets.constellation2))

            -- mark entity2 as active
            entity2:add(ComponentType2())
            assert.is_true(1 == table.getLength(testSystem.targets.constellation1))
            assert.is_true(2 == table.getLength(testSystem.targets.constellation2))
        end)
    end)
end)
