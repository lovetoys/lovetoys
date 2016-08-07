local lovetoys = require('lovetoys')
lovetoys.initialize({ globals = true })

describe('Eventmanager', function()
    local Listener, TestEvent
    local listener, eventManager, testEvent

    setup(
    function()
        -- Test Listener
        Listener = lovetoys.class('Listener')
        Listener.number = 0
        function Listener:test(event)
            self.number = event.number
        end
        -- Test Event
        TestEvent = lovetoys.class('TestEvent')
        TestEvent.number = 12
    end
    )

    before_each(
    function()
        eventManager = EventManager()
        listener = Listener()
        testEvent = TestEvent()
    end
    )

    it('addListener() adds Listener', function()
        eventManager:addListener('TestEvent', listener, listener.test)
        assert.are.equal(type(eventManager.eventListeners['TestEvent']), 'table')
        assert.are.equal(eventManager.eventListeners['TestEvent'][1][1], listener )
    end)

    it('addListener() doesn`t add Listener twice', function()
        eventManager:addListener('TestEvent', listener, listener.test)
        assert.are.equal(type(eventManager.eventListeners['TestEvent']), 'table')
        assert.are.equal(eventManager.eventListeners['TestEvent'][1][1].number , 0)
        -- Creation of new Listener with same name but different variable
        listener = Listener()
        listener.number = 5
        eventManager:addListener('TestEvent', listener, listener.test)
        assert.are_not.equal(eventManager.eventListeners['TestEvent'][1][1].number, 5)
    end)

    it('removeListener() removes Listener', function()
        eventManager:addListener('TestEvent', listener, listener.test)
        assert.are.equal(type(eventManager.eventListeners['TestEvent']), 'table')
        assert.are.equal(eventManager.eventListeners['TestEvent'][1][1], listener )

        eventManager:removeListener('TestEvent', listener.class.name)
        assert.are.equal(eventManager.eventListeners['TestEvent'][1], nil )
    end)

    it('fireEvent() listener Function is beeing called', function()
        eventManager:addListener('TestEvent', listener, listener.test)
        assert.are.equal(type(eventManager.eventListeners['TestEvent']), 'table')
        assert.are.equal(eventManager.eventListeners['TestEvent'][1][1], listener )

        eventManager:fireEvent(testEvent)
        assert.are.equal(eventManager.eventListeners['TestEvent'][1][1].number , testEvent.number)
    end)

end)
