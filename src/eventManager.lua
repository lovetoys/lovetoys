EventManager = class("EventManager")

function EventManager:__init()
    self.eventListeners = {}
end

-- Adding an eventlistener to a specific event
function EventManager:addListener(eventName, listener, listenerFunction)
    -- If there's no list for this event, we create a new one
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    -- Backward compability. This'll be removed in some time
    if not listenerFunction then
        for key, registeredListener in pairs(self.eventListeners[eventName]) do
            if registeredListener[1].__name == listener[1].__name then
                print("EventListener already existing. Aborting")
                return
            end
        end
        table.insert(self.eventListeners[eventName], listener)
    else
        for key, registeredListener in pairs(self.eventListeners[eventName]) do
            if registeredListener[1].__name == listener.__name then
                print("EventListener already existing. Aborting")
                return
            end
        end
        if type(listenerFunction) == 'function' then
            table.insert(self.eventListeners[eventName], {listener, listenerFunction})
        else
            print('Eventmanager: Second parameter has to be a function! Pls check ' .. listener.__name)
        end
    end
end

-- Removing an eventlistener from an event
function EventManager:removeListener(eventName, listener)
    if self.eventListeners[eventName] then
        for key, registeredListener in pairs(self.eventListener[eventName]) do
            if registeredListener[1].__name == listener then
                table.remove(self.eventListener[eventName], key)
                return
            end
        end
        print("Listener to be deleted is not existing.")
    end
end

-- Firing an event. All registered listener will react to this event
function EventManager:fireEvent(event)
    if self.eventListeners[event.__name] then
        for _,listener in pairs(self.eventListeners[event.__name]) do
            listener[2](listener[1], event)
        end
    end
end

