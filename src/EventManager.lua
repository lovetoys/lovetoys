EventManager = class("EventManager")

function EventManager:initialize()
    self.eventListeners = {}
end

-- Adding an eventlistener to a specific event
function EventManager:addListener(eventName, listener, listenerFunction)
    -- If there's no list for this event, we create a new one
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end

    for _, registeredListener in pairs(self.eventListeners[eventName]) do
        if registeredListener[1].class == listener.class then
            if lovetoyDebug then
                print("EventListener already existing. Aborting")
            end
            return
        end
    end
    if type(listenerFunction) == 'function' then
        table.insert(self.eventListeners[eventName], {listener, listenerFunction})
    else
        if lovetoyDebug then
            print('Eventmanager: Second parameter has to be a function! Pls check ' .. listener.class.name)
        end
    end
end

-- Removing an eventlistener from an event
function EventManager:removeListener(eventName, listener)
    if self.eventListeners[eventName] then
        for key, registeredListener in pairs(self.eventListeners[eventName]) do
            if registeredListener[1].class.name == listener then
                table.remove(self.eventListeners[eventName], key)
                return
            end
        end
        if lovetoyDebug then
            print("Listener to be deleted is not existing.")
        end
    end
end

-- Firing an event. All registered listener will react to this event
function EventManager:fireEvent(event)
    local name = event.class.name
    if self.eventListeners[name] then
        for _,listener in pairs(self.eventListeners[name]) do
            listener[2](listener[1], event)
        end
    end
end

