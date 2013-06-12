require("core/class")

Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.entityIndex = 0

    self.allSystems = {}
    self.logicSystems = {}
    self.drawSystems = {}

    self.eventListeners = {}

    self.IsEnemy = {}
    self.IsShot = {}
end

function Engine:addEntity(entity)
    self.entities[self.entityIndex] = entity
    entity.id = self.entityIndex
    self.entityIndex = self.entityIndex + 1
    self:refreshEntity(entity)

    -- Eingliederung der Entity in die jeweilige ComponentList
    for index, component in pairs(entity.components) do
        if self[component.__name] then
            table.insert(self[component.__name], entity)
        end
    end
end 

function Engine:removeEntity(entity)
    if self.entities[entity.id] then
        for key, system in pairs(self.allSystems) do
            for key2, systemEntity in pairs(system:getEntities()) do
                if systemEntity == entity then    
                    system:removeEntity(entity)
                end
            end
        end
        self.entities[entity.id] = nil
    end

    -- Löschen der jeweiligen Entity aus der ComponentList
    for index, component in pairs(entity.components) do
        if self[component.__name] then
            for index2, ent in pairs(self[component.__name]) do
                if entity == ent then 
                    table.remove(self[component.__name], index2)
                end
            end
        end
    end
end

function Engine:addSystem(system, type, index)
    if type == "draw" then
        table.insert(self.drawSystems, system)
    elseif type == "logic" then
        self.logicSystems[index] = system
    end
    table.insert(self.allSystems, system)
    return system
end

function Engine:update(dt)
    for index, system in ipairs(self.logicSystems) do
        system:update(dt)
    end
end

function Engine:draw()
    for index, system in ipairs(self.drawSystems) do
        system:draw()
    end
end

function Engine:refreshEntity(entity)
    if not self.entities[entity.id] then
        return
    end
    for index, system in pairs(self.allSystems) do
        local add = true
        local remove = false
        for index2, target in pairs(system:getEntities()) do
            if target == entity then
                add = false
            end
        end
        for index3, requiredComponent in pairs(system:getRequiredComponents()) do
            if not entity.components[requiredComponent] then
                add = false
                remove = true
            end
        end

        if add then
            system:addEntity(entity)
        elseif remove then
            system:removeEntity(entity)
        end
    end
end

-- Event stuff
function Engine:addListener(eventName, listener)
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    self.eventListeners[eventName][listener.__name] = listener
end

function Engine:removeListener(eventName, listener)
    if self.eventListeners[eventName] and self.eventListeners.eventName.listener then
        self.eventListeners[eventName][listener.__name] = nil
    end
end

function Engine:fireEvent(event)
    if self.eventListeners[event.name] then
        for k,v in pairs(self.eventListeners[event.name]) do
            v:fireEvent(event)
        end
    end
end