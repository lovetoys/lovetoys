require 'lovetoys'

describe('Eventmanager', function()
    describe('addListener()', function()
        it('adds Listener', function()
            local eventManager = EventManager()
            local Listener = class('Listener')
            local listener = Listener()
            function listener:test() end
            eventManager:addListener('testEvent', listener, listener.test)
            assert.is_true(type(eventManager.eventListeners['testEvent']) == 'table')
            assert.is_true(eventManager.eventListeners['testEvent'][1][1] == listener )
        end)
        it('doesn`t add Listener twice', function()
            local eventManager = EventManager()
            local Listener = class('Listener')
            local listener = Listener()
            listener.number = 0
            function listener:test() end
            eventManager:addListener('testEvent', listener, listener.test)
            assert.is_true(type(eventManager.eventListeners['testEvent']) == 'table')
            assert.is_true(eventManager.eventListeners['testEvent'][1][1].number  == 0)

            -- Creation of new Listener with same name but different variable
            listener = Listener()
            listener.number = 5
            function listener:test() end
            eventManager:addListener('testEvent', listener, listener.test)
            assert.is_true(eventManager.eventListeners['testEvent'][1][1].number  == 0)
        end)
    end)
    describe('removeListener()', function()
        it('removes Listener', function()
            local eventManager = EventManager()
            local Listener = class('Listener')
            local listener = Listener()
            function listener:test() end
            eventManager:addListener('testEvent', listener, listener.test)
            assert.is_true(type(eventManager.eventListeners['testEvent']) == 'table')
            assert.is_true(eventManager.eventListeners['testEvent'][1][1] == listener )

            eventManager:removeListener('testEvent', listener.__name)
            assert.is_true(eventManager.eventListeners['testEvent'][1][1] == nil )
        end)
    end)
    describe('fireEvent()', function()
        it('listener Function is beeing called', function()
            local eventManager = EventManager()
            local Listener = class('Listener')
            local listener = Listener()
            listener.number = 0
            function listener:test(event) 
                self.number = event.number
            end
            eventManager:addListener('testEvent', listener, listener.test)
            assert.is_true(type(eventManager.eventListeners['testEvent']) == 'table')
            assert.is_true(eventManager.eventListeners['testEvent'][1][1] == listener )

            local TestEvent = class('TestEvent')
            testEvent = TestEvent()
            testEvent.number = 12
            eventManager:fireEvent(testEvent)

            assert.is_true(eventManager.eventListeners['testEvent'][1][1].number  == testEvent.number)
        end)
    end)
end)
