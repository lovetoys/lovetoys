
-- Getting folder that contains engine
local folderOfThisFile = (...):match("(.-)[^%/]+$")

-- Requiring class
require(folderOfThisFile .. "class")

-- Requiring all Events
require(folderOfThisFile .. "events/componentAdded")
require(folderOfThisFile .. "events/componentRemoved")
require(folderOfThisFile .. "events/beginContact")

-- Requiring the lovetoys
require(folderOfThisFile .. "entity")
require(folderOfThisFile .. "system")
require(folderOfThisFile .. "eventManager")
require(folderOfThisFile .. "collisionManager")
require(folderOfThisFile .. "component")


Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.requirements = {}
    self.entityLists = {}
    self.eventManager = EventManager()

    self.allSystems = {}
    self.logicSystems = {}
    self.drawSystems = {}

    self.freeIds = {}
    self.eventManager:addListener("ComponentRemoved", {self, self.componentRemoved})
    self.eventManager:addListener("ComponentAdded", {self, self.componentAdded})
end

function Engine:addEntity(entity)
    
    entity.eventManager = self.eventManager

    -- Getting the next free ID or insert into table
    if #self.freeIds == 0 then
        table.insert(self.entities, entity)
        entity.id = #self.entities
    else
        entity.id = self.freeIds[#self.freeIds]
        self.entities[entity.id] = entity
        table.remove(self.freeIds, #self.freeIds)
    end
    for index, component in pairs(entity.components) do
        -- Adding Entity to specific Entitylist
        self.entityLists[component.__name] = self.entityLists[component.__name] or {}
        self.entityLists[component.__name][entity.id] = entity

        -- Adding Entity to System if all requirements are granted
        if self.requirements[component.__name] then
            for index2, system in pairs(self.requirements[component.__name]) do
                local meetsRequirements = true
                for index3, requirement in pairs(system:getRequiredComponents()) do
                    if meetsRequirements == true then
                        for index4, component in pairs(entity.components) do
                            if component.__name == requirement then
                                meetsRequirements = true
                                break
                            else
                                meetsRequirements = false
                            end
                        end
                    else
                        break 
                    end
                end
                if meetsRequirements == true then
                    system:addEntity(entity)
                end
            end
        end
    end
end 

function Engine:removeEntity(entity)
    if self.entities[entity.id] == entity then
        -- Stashing the id of the removed Entity in self.freeIds
        table.insert(self.freeIds, entity.id)
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
            if self.entityLists[component.__name] then
                self.entityLists[component.__name][entity.id] = nil
            end
        end
        self.entities[entity.id] = nil
    end
end

function Engine:addSystem(system, type, priority)
    if priority then
        system.priority = priority
    end
    -- Adding System to draw or logic table
    if type == "draw" then
        table.insert(self.drawSystems, system)
        table.sort(self.drawSystems, function(a, b) return a.priority < b.priority end)
    elseif type == "logic" then
        table.insert(self.logicSystems, system)
        table.sort(self.logicSystems, function(a, b) return a.priority < b.priority end)
    end
    table.insert(self.allSystems, system)

    -- Registering the systems requirements and saving them in a special table for fast access
    for index, value in pairs(system:getRequiredComponents()) do
        self.requirements[value] = self.requirements[value] or {}
        table.insert(self.requirements[value], system)
    end
    -- Checks if some of the already entities match the required components.
    for k, entity in pairs(self.entities) do
        local meetsRequirements = true
        for k2, requirement in pairs(system:getRequiredComponents()) do
            if meetsRequirements == true then
                for index4, component in pairs(entity.components) do
                    if component.__name == requirement then
                        meetsRequirements = true
                        break
                    else
                        meetsRequirements = false
                    end
                end
            else
                break 
            end
        end
        if meetsRequirements == true then
            system:addEntity(entity)
        end
    end
    return system
end

function Engine:removeSystem(system, type)
    
    local requirements
    -- Removes it from the allSystem list
    for k, v in pairs(self.allSystems) do
        if v.__name == system then
            requirements = v:getRequiredComponents()
            table.remove(self.allSystems, k)
        end
    end
    
    --  Remove the System from all requirement lists
    for k, v in pairs(requirements) do
        for k2, v2 in pairs(self.requirements[v]) do
            if v2.__name == system then
                table.remove(self.requirements, k2)
            end
        end
    end

    -- Remove the system from all systemlists
    if type == "draw" then
        for k, v in pairs(self.drawSystems) do
            if v.__name == system then
                table.remove(self.drawSystems, k)
            end
        end
    elseif type == "logic" then
        for k, v in pairs(self.logicSystems) do
            if v.__name == system then
                table.remove(self.logicSystems, k)
            end
        end
    end
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

function Engine.componentRemoved(self, event)
    local entity = event.entity
    local component = event.component
    -- Removing Entity from Entitylists
    self.entityLists[component][entity.id] = nil
    -- Removing Entity from old systems
    if self.requirements[component] then
        for i2, system in pairs(self.requirements[component]) do 
            system:removeEntity(entity)
        end
    end
end

function Engine.componentAdded(self, event)
    local entity = event.entity
    local component = event.component
    -- Adding the Entity to Entitylist
    if self.entityLists[component] then
        self.entityLists[component][entity.id] = entity
    else
        self.entityLists[component] = {}
        self.entityLists[component][entity.id] = entity
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

-- Returns an Entitylist for a specific component. If the Entitylist doesn't exists yet it'll be created and returned.
function Engine:getEntityList(component)
    if self.entityLists[component] then
        return self.entityLists[component]
    else
        self.entityLists[component] = {}
        return self.entityLists[component]
    end
end