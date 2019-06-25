local lovetoys = require('')
lovetoys.initialize()

describe('System', function()
    local MultiSystem, RequireSystem
    local entity, entity1, entity2
    local multiSystem, engine

    setup(
      function()
          MultiSystem = lovetoys.class('MultiSystem', lovetoys.System)
          function MultiSystem:requires()
              return {ComponentType1 = {'Component1'}, ComponentType2 = {'Component'}}
          end

          RequireSystem = lovetoys.class('RequireSystem', lovetoys.System)
          function RequireSystem:requires()
              return {'Component1', 'Component2'}
          end
      end
    )

    before_each(
      function()
          entity = lovetoys.Entity()
          entity.id = 1
          entity1 = lovetoys.Entity()
          entity1.id = 1
          entity2 = lovetoys.Entity()
          entity2.id = 2

          multiSystem = MultiSystem()
          requireSystem = RequireSystem()
          engine = lovetoys.Engine()
      end
    )

    it(':addEntity() adds single', function()
        multiSystem:addEntity(entity)

        assert.are.equal(multiSystem.targets[1], entity)
    end)

    it(':addEntity() adds entities into different categories', function()
        engine:addSystem(multiSystem)

        multiSystem:addEntity(entity1, 'ComponentType1')
        multiSystem:addEntity(entity2, 'ComponentType2')

        assert.are.equal(multiSystem.targets['ComponentType1'][1], entity1)
        assert.are.equal(multiSystem.targets['ComponentType2'][2], entity2)
    end)

    it(':removeEntity() removes single', function()
        multiSystem:addEntity(entity, 'ComponentType1')
        assert.are.equal(multiSystem.targets['ComponentType1'][1], entity)

        multiSystem:removeEntity(entity)
        assert.is_equal(#multiSystem.targets['ComponentType1'], 0)
    end)

    it(':pickRequiredComponents() returns the requested components', function()
        local addedComponent1 = lovetoys.class('Component1')()
        entity:add(addedComponent1)
        requireSystem:addEntity(entity)

        local returnedComponent1, nonExistentComponent = requireSystem:pickRequiredComponents(entity)
        assert.are.equal(returnedComponent1, addedComponent1)
        assert.is_nil(nonExistentComponent)
    end)

    it(':pickRequiredComponents() throws debug message on multiple requirement systems', function()

        local addedComponent1 = lovetoys.class('Component1')()
        entity:add(addedComponent1)
        multiSystem:addEntity(entity)

        -- Mock lovetoys debug function
        local debug_spy = spy.on(lovetoys, 'debug')

        local returnValue = multiSystem:pickRequiredComponents(entity)
        assert.are.equal(returnValue, nil)

        -- Check for called debug message
        assert.spy(debug_spy).was_called()
        lovetoys.debug:revert()
    end)

    it(':initialize() shouldnt allow mixed requirements in requires()', function()
         local IllDefinedSystem = lovetoys.class('IllDefinedSystem', lovetoys.System)
         function IllDefinedSystem:requires()
             return {'ComponentA', GroupA = {'ComponentB'}}
         end
         assert.has_error(IllDefinedSystem)
    end)

    it(':removeEntity calls onRemoveEntity for system with requirement groups', function()
         local Component1 = lovetoys.class('Component1')
         entity:add(Component1())

         local cb_spy = spy.on(multiSystem, 'onRemoveEntity')
         multiSystem:addEntity(entity, 'ComponentType1')
         multiSystem:removeEntity(entity)

         assert.spy(cb_spy).was.called_with(multiSystem, entity, 'ComponentType1')
         assert.spy(cb_spy).was.called(1)
    end)

    it(':removeEntity calls onRemoveEntity for system with no requirement groups', function()
         local Component1 = lovetoys.class('Component1')
         entity:add(Component1())

         local cb_spy = spy.on(requireSystem, 'onRemoveEntity')

         requireSystem:addEntity(entity)
         requireSystem:removeEntity(entity)

         assert.spy(cb_spy).was.called_with(requireSystem, entity)
         assert.spy(cb_spy).was.called(1)
    end)
end)
