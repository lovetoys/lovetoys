EventManager = class("EventManager")

function EventManager:__init()
    self.eventListeners = {}
end

function EventManager:getKey(table, element)
    for index, value in pairs(table) do
        if value == element then
            return index
        end
        return false
    end
end

-- Adding an eventlistener to a specific event
function EventManager:addListener(eventName, listener)
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    table.insert(self.eventListeners[eventName], listener)
end

-- Removing an eventlistener from an event
function EventManager:removeListener(eventName, listener)
    if self.eventListeners[eventName] and self:getKey(self.eventListener[eventName], listener) then
        table.remove(self.eventListener[eventName], self:getKey(self.eventListener[eventName], listener))
    end
end

-- Firing an event. All registered listener will react to this event
function EventManager:fireEvent(event)
    if self.eventListeners[event.__name] then
        for k,v in pairs(self.eventListeners[event.__name]) do
            v[2](v[1], event)
        end
    end
end

