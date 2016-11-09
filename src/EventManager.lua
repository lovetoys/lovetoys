-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local lovetoys = require(folderOfThisFile .. 'namespace')
local EventManager = lovetoys.class("EventManager")

function EventManager:initialize()
    self.eventListeners = {}
end

-- Adding an eventlistener to a specific event
function EventManager:addListener(eventName, listener, listenerFunction)
    -- If there's no list for this event, we create a new one
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end




    if not listener.class or (listener.class and not listener.class.name) then
        lovetoys.debug('Eventmanager: The listener has to implement a listener.class.name field.')
    end

    for _, registeredListener in pairs(self.eventListeners[eventName]) do
        if registeredListener[1].class == listener.class then
            lovetoys.debug(
                string.format("Eventmanager: EventListener for {} already exists.", eventName))
            return
        end
    end
    if type(listenerFunction) == 'function' then
        table.insert(self.eventListeners[eventName], {listener, listenerFunction})
    else
        lovetoys.debug('Eventmanager: Third parameter has to be a function! Please check listener for ' .. eventName)
        if listener.class and listener.class.name then
            lovetoys.debug('Eventmanager: Listener class name: ' .. listener.class.name)
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
        lovetoys.debug(string.format("Eventmanager: Listener %s to be deleted on Event %s  is not existing.", listener.class.name, eventName))
    end
    lovetoys.debug(string.format("Eventmanager: Event %s listener should be removed from is not existing ", eventName))
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

return EventManager
