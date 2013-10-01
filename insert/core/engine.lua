Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.entityIndex = 0
    self.requirements = {}

    self.allSystems = {}
    self.logicSystems = {}
    self.drawSystems = {}

    self.eventListeners = {}
    self.stack = {}
end

function Engine:addEntity(entity)
    if #self.stack == 0 then
        table.insert(self.entities, entity)
        entity.id = #self.entities
    else
        entity.id = self.stack[#self.stack]
        self.entities[entity.id] = entity
        table.remove(self.stack, #self.stack)
    end
    for index, component in pairs(entity.components) do
        -- Adding Entity to specific Entitylist
        if not self[component.__name] then self[component.__name] = {} end
        self[component.__name][entity.id] = entity

        -- Adding Entity to System if all requirements are granted
        if self.requirements[component.__name] then
            for index2, system in pairs(self.requirements[component.__name]) do
                local check = true
                for index3, requirement in pairs(system:getRequiredComponents()) do
                    if check == true then
                        for index4, component in pairs(entity.components) do
                            if component.__name == requirement then
                                check = true
                                break
                            else
                                check = false
                            end
                        end
                    else
                        break 
                    end
                end
                if check == true then
                    system:addEntity(entity)
                end
            end
        end
    end
end 

function Engine:removeEntity(entity)
    if self.entities[entity.id] == entity then
        -- Stashing the id of the removed Entity in self.stack
        table.insert(self.stack, entity.id)
        -- Removing the Entity from all Systems and engine
        for i, component in pairs(entity.components) do
            if self.requirements[component.__name] then
                for i2, system in pairs(self.requirements[component.__name]) do
                    system:removeEntity(entity)
                end
            end
        end
        -- Deleting the Entity from the specific entity lists
        for index, component in pairs(entity.components) do
            if self[component.__name] then
                self[component.__name][entity.id] = nil
            end
        end
        self.entities[entity.id] = nil
    end
end

function Engine:addSystem(system, type, index)
    -- Adding System to draw or logic table
    if type == "draw" then
        table.insert(self.drawSystems, system)
    elseif type == "logic" then
        table.insert(self.logicSystems, system)
    end
    table.insert(self.allSystems, system)

    -- Registering the systems requirements and saving them in a special table for fast access
    for index, value in pairs(system:getRequiredComponents()) do
        if not self.requirements[value] then
            self.requirements[value] = {}
        end
        table.insert(self.requirements[value], system)
    end
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
    -- Enable to get white boxes around Bodies with polygonshapes
    --[[ 
    for key, entity in pairs(self:getEntitylist("PhysicsComponent")) do
        x1, y1, x2, y2 = entity:getComponent("PhysicsComponent").fixture:getBoundingBox()
        if entity:getComponent("PhysicsComponent").shape.getPoints then
            love.graphics.polygon("fill", entity:getComponent("PhysicsComponent").body:getWorldPoints(entity:getComponent("PhysicsComponent").shape:getPoints()))
        end
    end
    --]]--
end

function Engine:componentRemoved(entity, removed)
    if removed then
        for i, component in pairs(removed) do
            -- Removing Entity from Entitylists
            self[component][entity.id] = nil
            -- Removing Entity from old systems
            if self.requirements[component] then
                for i2, system in pairs(self.requirements[component]) do 
                    system:removeEntity(entity)
                end
            end
        end
    end
end

function Engine:componentAdded(entity, added)
    for i, component in pairs(added) do
        -- Adding the Entity to Entitylist
        if self[component] then
            table.insert(self[component], entity)
        else
            self[component] = {}
            table.insert(self[component], entity)
        end
        -- Adding the Entity to the requiring systems
        if self.requirements[component] then
            for i2, system in pairs(self.requirements[component]) do
                local add = true
                for i3, req in pairs(system.getRequiredComponents()) do
                    for i3, comp in pairs(entity.components) do
                        if comp.__name == req then
                            add = true
                            break
                        else
                            add = false
                        end
                    end
                end
                if add == true then
                    system:addEntity(entity)
                end
            end
        end
    end
end

-- Returns an Entitylist for a specific component. If the Entitylist doesn't exists yet it'll be created and returned.
function Engine:getEntitylist(component)
    if self[component] then
        return self[component]
    else
        self[component] = {}
        return self[component]
    end
end

-- Adding an eventlistener to a specific event
function Engine:addListener(eventName, listener)
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    self.eventListeners[eventName][listener.__name] = listener
end

-- Removing an eventlistener from an event
function Engine:removeListener(eventName, listener)
    if self.eventListeners[eventName] and self.eventListeners.eventName.listener then
        self.eventListeners[eventName][listener.__name] = nil
    end
end

-- Firing an event. All regiestered listener will react to this event
function Engine:fireEvent(event)
    if self.eventListeners[event.__name] then
        for k,v in pairs(self.eventListeners[event.__name]) do
            v:fireEvent(event)
        end
    end
end
