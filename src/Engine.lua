-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local lovetoys = require(folderOfThisFile .. 'namespace')
local Engine = lovetoys.class("Engine")

function Engine:initialize()
    self.entities = {}
    self.rootEntity = lovetoys.Entity()
    self.singleRequirements = {}
    self.allRequirements = {}
    self.entityLists = {}
    self.eventManager = lovetoys.EventManager()

    self.systems = {}
    self.systemRegistry = {}
    self.systems["update"] = {}
    self.systems["draw"] = {}

    self.eventManager:addListener("ComponentRemoved", self, self.componentRemoved)
    self.eventManager:addListener("ComponentAdded", self, self.componentAdded)
end

function Engine:addEntity(entity)
    -- Setting engine eventManager as eventManager for entity
    entity.eventManager = self.eventManager
    -- Getting the next free ID or insert into table
    local newId = #self.entities + 1
    entity.id = newId
    self.entities[entity.id] = entity

    -- If a rootEntity entity is defined and the entity doesn't have a parent yet, the rootEntity entity becomes the entity's parent
    if entity.parent == nil then
        entity:setParent(self.rootEntity)
    end
    entity:registerAsChild()

    for _, component in pairs(entity.components) do
        local name = component.class.name
        -- Adding Entity to specific Entitylist
        if not self.entityLists[name] then self.entityLists[name] = {} end
        self.entityLists[name][entity.id] = entity

        -- Adding Entity to System if all requirements are granted
        if self.singleRequirements[name] then
            for _, system in pairs(self.singleRequirements[name]) do
                self:checkRequirements(entity, system)
            end
        end
    end
end

function Engine:removeEntity(entity, removeChildren, newParent)
    if self.entities[entity.id] then
        -- Removing the Entity from all Systems and engine
        for _, component in pairs(entity.components) do
            local name = component.class.name
            if self.singleRequirements[name] then
                for _, system in pairs(self.singleRequirements[name]) do
                    system:removeEntity(entity)
                end
            end
        end
        -- Deleting the Entity from the specific entity lists
        for _, component in pairs(entity.components) do
            self.entityLists[component.class.name][entity.id] = nil
        end

        -- If removeChild is defined, all children become deleted recursively
        if removeChildren then
            for _, child in pairs(entity.children) do
                self:removeEntity(child, true)
            end
        else
            -- If a new Parent is defined, this Entity will be set as the new Parent
            for _, child in pairs(entity.children) do
                if newParent then
                    child:setParent(newParent)
                else
                    child:setParent(self.rootEntity)
                end
                -- Registering as child
                entity:registerAsChild()
            end
        end
        -- Removing Reference to entity from parent
        for _, _ in pairs(entity.parent.children) do
            entity.parent.children[entity.id] = nil
        end
        -- Setting status of entity to dead. This is for other systems, which still got a hard reference on this
        self.entities[entity.id].alive = false
        -- Removing entity from engine
        self.entities[entity.id] = nil
    else
        lovetoys.debug("Engine: Trying to remove non existent entity from engine.")
        if entity.id then
            lovetoys.debug("Engine: Entity id: " .. entity.id)
        else
            lovetoys.debug("Engine: Entity has not been added to any engine yet. (No entity.id)")
        end
        lovetoys.debug("Engine: Entity's components:")
        for index, component in pairs(entity.components) do
            lovetoys.debug(index, component)
        end
    end
end

function Engine:addSystem(system, systemType)
    local name = system.class.name

    -- Check if the specified type is correct
    if systemType ~= nil and systemType ~= "draw" and systemType ~= "update" then
        lovetoys.debug("Engine: Trying to add System " .. name .. "with invalid type " .. systemType .. ". Aborting")
        return
    end

    -- Check if a type should be specified
    if system.draw and system.update and not systemType then
        lovetoys.debug("Engine: Trying to add System " .. name .. ", which has an update and a draw function, without specifying type. Aborting")
        return
    end

    -- Check if the user is accidentally adding two instances instead of one
    if self.systemRegistry[name] and self.systemRegistry[name] ~= system then
        lovetoys.debug("Engine: Trying to add two different instances of the same system. Aborting.")
        return
    end

    -- Assert that system:excludes returns the same structure as system:requires or an empty list.
    requires = system:requires()
    excludes = system:excludes()
    firstElement = lovetoys.util.firstElement
    one_is_table = type(firstElement(requires)) == "table" or type(firstElement(excludes)) == "table"
    both_are_table = type(firstElement(requires)) == "table" and type(firstElement(excludes)) == "table"
    if one_is_table then
        -- Check if the system has excludes.
        if lovetoys.util.listLength(excludes) > 0 then
            -- One of both, `excludes` or `requires`, returns a list, the other doesn't.
            if not both_are_table then
                lovetoys.debug("System: " .. name .. " has different list structures for :requires() and :excludes().")
                return
            end
            -- Check if the keys for both categories match. We only need to check from requires to excludes, as this is what matters.
            for category, _ in requires do
                if not exclude[category] then
                    lovetoys.debug("System: " .. name .. " has different category names for :requires() and :excludes().")
                    return
                end
            end
        end
    end

    -- Adding System to engine system reference table
    if not (self.systemRegistry[name]) then
        self:registerSystem(system)
    -- This triggers if the system doesn't have update and draw and it's already existing.
    elseif not (system.update and system.draw) then
        if self.systemRegistry[name] then
            lovetoys.debug("Engine: System " .. name .. " already exists. Aborting")
            return
        end
    end

    -- Adding System to draw table
    if system.draw and (not systemType or systemType == "draw") then
        for _, registeredSystem in pairs(self.systems["draw"]) do
            if registeredSystem.class.name == name then
                lovetoys.debug("Engine: System " .. name .. " already exists. Aborting")
                return
            end
        end
        table.insert(self.systems["draw"], system)
    -- Adding System to update table
    elseif system.update and (not systemType or systemType == "update") then
        for _, registeredSystem in pairs(self.systems["update"]) do
            if registeredSystem.class.name == name then
                lovetoys.debug("Engine: System " .. name .. " already exists. Aborting")
                return
            end
        end
        table.insert(self.systems["update"], system)
    end

    -- Checks if some of the already existing entities match the required components.
    for _, entity in pairs(self.entities) do
        self:checkRequirements(entity, system)
    end
    return system
end

-- Register a System to the Engine. This is done once or twice for each System,
-- depending if it has either a draw or update method or both of them.

-- There are a few things happening in this function:
--
-- First the system is added to the global System registry
-- Next we add the System to several requirement lists:
-- `singleRequirements`: This is a list where Component names are mapped to lists of Systems.
--      Each system exists only *once* or *max the number of multiple requirement categories* in this collection.
--      During registration we take the first Component name of every requirement list
--      and add the system to this specific list e.g.:
--          table.insert(singleRequirement['first'], system)
--      This list is really useful to check requirements only once per system during entity addition instead of n times.
-- `allRequirements`: This is a list where Component names are mapped to lists of systems.
--      In here we can find every System that requires a specific Component.
--      We need this to notify Systems in case an Entity has Components added or removed.
--
function Engine:registerSystem(system)
    -- Shortcut variables
    local name = system.class.name
    local firstElement = lovetoys.util.firstElement

    self.systemRegistry[name] = system
    -- case: system:requires() returns a table of strings
    if system:requires()[1] and type(system:requires()[1]) == "string" then
        for index, req in pairs(system:requires()) do
            -- Registering at singleRequirements
            if index == 1 then
                self.singleRequirements[req] = self.singleRequirements[req] or {}
                table.insert(self.singleRequirements[req], system)
            end
            -- Registering at allRequirements
            self.allRequirements[req] = self.allRequirements[req] or {}
            table.insert(self.allRequirements[req], system)
        end
    end

    -- case: system:requires() returns a table of tables which contain strings
    if firstElement(system:requires()) and type(firstElement(system:requires())) == "table" then
        for index, componentList in pairs(system:requires()) do
            -- Registering at singleRequirements
            local component = componentList[1]
            self.singleRequirements[component] = self.singleRequirements[component] or {}
            table.insert(self.singleRequirements[component], system)

            -- Registering at allRequirements
            for _, req in pairs(componentList) do
                self.allRequirements[req] = self.allRequirements[req] or {}
                -- Check if this List already contains the System
                local contained = false
                for _, registeredSystem in pairs(self.allRequirements[req]) do
                    if registeredSystem == system then
                        contained = true
                        break
                    end
                end
                if not contained then
                    table.insert(self.allRequirements[req], system)
                end
            end
            -- Create tables for multiple requirements in the system's target directory
            system.targets[index] = {}
        end
    end
end

function Engine:stopSystem(name)
    if self.systemRegistry[name] then
        self.systemRegistry[name].active = false
    else
        lovetoys.debug("Engine: Trying to stop not existing System: " .. name)
    end
end

function Engine:startSystem(name)
    if self.systemRegistry[name] then
        self.systemRegistry[name].active = true
    else
        lovetoys.debug("Engine: Trying to start not existing System: " .. name)
    end
end

function Engine:toggleSystem(name)
    if self.systemRegistry[name] then
        self.systemRegistry[name].active = not self.systemRegistry[name].active
    else
        lovetoys.debug("Engine: Trying to toggle not existing System: " .. name)
    end
end

function Engine:update(dt)
    for _, system in ipairs(self.systems["update"]) do
        if system.active then
            system:update(dt)
        end
    end
end

function Engine:draw()
    for _, system in ipairs(self.systems["draw"]) do
        if system.active then
            system:draw()
        end
    end
end

function Engine:componentRemoved(event)
    -- In case a single component gets removed from an entity, we inform
    -- all systems that this entity lost this specific component.
    local entity = event.entity
    local component = event.component

    -- Removing Entity from Entity lists
    self.entityLists[component][entity.id] = nil

    -- Removing Entity from systems
    if self.allRequirements[component] then
        for _, system in pairs(self.allRequirements[component]) do
            system:componentRemoved(entity, component)
        end
    end
end

function Engine:componentAdded(event)
    local entity = event.entity
    local component = event.component

    -- Adding the Entity to Entitylist
    if not self.entityLists[component] then self.entityLists[component] = {} end
    self.entityLists[component][entity.id] = entity

    -- Adding the Entity to the requiring systems
    if self.allRequirements[component] then
        for _, system in pairs(self.allRequirements[component]) do
            self:checkRequirements(entity, system)
        end
    end
end

function Engine:getRootEntity()
    if self.rootEntity ~= nil then
        return self.rootEntity
    end
end

-- Returns an list with all Entity owning a specific component. If the Entity list doesn't exist yet it'll be created and returned.
function Engine:getEntitiesWithComponent(component)
    if not self.entityLists[component] then self.entityLists[component] = {} end
    return self.entityLists[component]
end

-- Returns a count of existing Entities with a given component
function Engine:getEntityCount(component)
    local count = 0
    if self.entityLists[component] then
        count = lovetoys.util.listLength(self.entityLists[component])
    end
    return count
end

-- This function check, if an Entity satisfies all requirements of a specific system
function Engine:checkRequirements(entity, system) -- luacheck: ignore self
    -- Do a quick lookup, if the Entity already is in the system.
    -- This is a log(n) lookup and should prevent multiple n*log(m)
    -- runs of the same Entity on the same system.
    --Overall performance should be better
    if system.targets[entity.id] then return end


    local meetsRequirements = true
    local category = nil

    -- Variables to allow checking of the exclude logic with multiple requirement categories
    -- The blacklist decides if the entity is excluded for a specific category.
    -- The has_exclusions variable is needed to check if there are any excludes at all.
    --     If that's the case we can skip the blacklist lookup.
    local excluded_table_blacklist = {}
    local has_exclusions = lovetoys.util.listLength(system:excludes())

    -- Check for excludes
    for index, exclude in pairs(system:excludes()) do
        -- Normal case: system:excludes() returns a list of Component name strings.
        if type(exclude) == "string" then
            -- The Entity contains an excluded component. Early return.
            if entity.components[exclude] then return end

        -- The requirements of the System are split into multiple
        -- target categories. The system:excludes function needs to return
        -- a list with the same structure as system:requires.
        elseif type(req) == "table" then
            for _, nested_exclude in pairs(exclude) do
                if not entity.components[nested_exclude] then
                    excluded_table_blacklist[index] = true
                    break
                end
            end
            excluded_table_blacklist[index] = false
        end
    end


    -- This is the actual requirement check
    for index, req in pairs(system:requires()) do
        -- Normal case: system:requires() returns a list of Component name strings.
        if type(req) == "string" then
            -- Requirement is not fulfilled, perform early return
            if not entity.components[req] then return end

        -- The requirements of the System are split into multiple
        -- target categories. Each category is handled separately.
        elseif type(req) == "table" then
            -- Check if the entity is blacklisted for this category
            if has_exclusions > 0 and excluded_table_blacklist[index] then break end

            -- Check if the requirements are satisfied for this category
            meetsRequirements = true
            for _, req2 in pairs(req) do
                if not entity.components[req2] then
                    meetsRequirements = false
                    break
                end
            end
            if meetsRequirements == true then
                category = index
                system:addEntity(entity, category)
            end
        end
    end
    if meetsRequirements == true and category == nil then
        system:addEntity(entity)
    end
end

return Engine
