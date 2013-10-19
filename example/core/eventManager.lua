EventManager = class("EventManager")

function EventManager:__init()
    self.eventListeners = {}
end

-- Adding an eventlistener to a specific event
function EventManager:addListener(eventName, listener)
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    self.eventListeners[eventName][listener.__name] = listener
end

-- Removing an eventlistener from an event
function EventManager:removeListener(eventName, listener)
    if self.eventListeners[eventName] and self.eventListeners.eventName.listener then
        self.eventListeners[eventName][listener.__name] = nil
    end
end

-- Firing an event. All regiestered listener will react to this event
function EventManager:fireEvent(event)
    if self.eventListeners[event.__name] then
        for k,v in pairs(self.eventListeners[event.__name]) do
            v:fireEvent(event)
        end
    end
end
