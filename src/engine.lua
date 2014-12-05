Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.rootEntity = Entity()
    self.requirements = {}
    self.entityLists = {}
    self.eventManager = EventManager()

    self.systems = {}
    self.systems["all"] = {}
    self.systems["update"] = {}
    self.systems["draw"] = {}

    self.freeIds = {}
    self.maxId = 1
    self.eventManager:addListener("ComponentRemoved", {self, self.componentRemoved})
    self.eventManager:addListener("ComponentAdded", {self, self.componentAdded})
end

function Engine:addEntity(entity)
    -- Setting engine eventManager as eventManager for entity
    entity.eventManager = self.eventManager
    -- Getting the next free ID or insert into table
    if #self.freeIds == 0 then
        entity.id = self.maxId
        self.maxId = self.maxId + 1
        table.insert(self.entities, entity)
    else
        entity.id = table.remove(self.freeIds, #self.freeIds)
        self.entities[entity.id] = entity
    end

    -- If a rootEntity entity is defined and the entity doesn't have a parent yet, the rootEntity entity becomes the entity's parent
    if entity.parent == nil then
        entity:setParent(self.rootEntity)
    end
    entity:registerAsChild()

    for index, component in pairs(entity.components) do
        -- Adding Entity to specific Entitylist
        if not self.entityLists[component.__name] then self.entityLists[component.__name] = {} end
        self.entityLists[component.__name][entity.id] = entity

        -- Adding Entity to System if all requirements are granted
        if self.requirements[component.__name] then
            for index2, system in pairs(self.requirements[component.__name]) do
                self:checkRequirements(entity, system)
            end
        end
    end
end 

function Engine:removeEntity(entity, removeChildren)
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
        self.entityLists[component.__name][entity.id] = nil
    end
    if self.entities[entity.id] then
        -- If removeChild is defined, all children become deleted recursively
        if removeChildren then
            for _, child in pairs(entity.children) do
                self:removeEntity(child, true)
            end
        else
            for _, child in pairs(entity.children) do
                if self.rootEntity then
                    child:setParent(self.rootEntity)
                else
                    child.parent = nil
                end
            end
        end
        -- Removing Reference to entity from parent
        for index, child in pairs(entity.parent.children) do
            entity.parent.children[entity.id] = nil
        end
        -- Setting status of entity to dead. This is for other systems, which still got a hard reference on this
        self.entities[entity.id].alive = false
        -- Removing entity from engine
        self.entities[entity.id] = nil
    else
        print("Trying to remove non existent entity from engine.")
        print("Entity id: " .. entity.id)
        print("Entity's components:")
        for index, component in pairs(entity.components) do
            print(index)
        end
    end
end

function Engine:addSystem(system, typ)
    -- Adding System to draw or update table
    if typ == "draw" or (system.draw and not system.update) then
        for index, value in pairs(self.systems["draw"]) do
            if value.__name == system.__name then
                print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                return
            end
        end
        table.insert(self.systems["draw"], system)
    elseif typ == "update" or  (system.update and not system.draw) then
        for index, value in pairs(self.systems["update"]) do
            if value.__name == system.__name then
                print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                return
            end
        end
        table.insert(self.systems["update"], system)
    elseif typ == nil and system.update and system.draw then
        print("Lovetoys: " .. system.__name .. " has update and draw function. Please add it twice with 'draw' and 'update' specification. Aborting")
    else
        for index, value in pairs(self.systems["all"]) do
            if value.__name == system.__name then
                print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                return
            end
        end
    end
    table.insert(self.systems["all"], system)

    -- Registering the systems requirements and saving them in a special table for fast access
    for index, value in pairs(system:requires()) do
        if type(value) == "string" then
            self.requirements[value] = self.requirements[value] or {}
            table.insert(self.requirements[value], system)
        elseif type(value) == "table" then
            for index2, string in pairs(value) do
                self.requirements[string] = self.requirements[string] or {}
                table.insert(self.requirements[string], system)
            end
            system.targets[index] = {}
        end
    end
    -- Checks if some of the already entities match the required components.
    for index, entity in pairs(self.entities) do
        self:checkRequirements(entity, system)
    end
    return system
end

function Engine:stopSystem(name)
    for index, system in pairs(self.systems["all"]) do
        if name == system.__name then
            system.active = false
        end
    end
end

function Engine:startSystem(name)
    for index, system in pairs(self.systems["all"]) do
        if name == system.__name then
            system.active = true
        end
    end
end

function Engine:toggleSystem(name)
    for index, system in pairs(self.systems["all"]) do
        if name == system.__name then
            system.active = not system.active
        end
    end
end


function Engine:update(dt)
    for index, system in ipairs(self.systems["update"]) do
        if system.active then
            system:update(dt)
        end
    end
end

function Engine:draw()
    for index, system in ipairs(self.systems["draw"]) do
        if system.active then
            system:draw()
        end
    end
end

function Engine.componentRemoved(self, event)
    local entity = event.entity
    local component = event.component
    -- Removing Entity from Entitylists
    self.entityLists[component][entity.id] = nil
    -- Removing Entity from old systems
    if self.requirements[component] then
        for index, system in pairs(self.requirements[component]) do 
            system:removeEntity(entity)
        end
    end
end

function Engine.componentAdded(self, event)
    local entity = event.entity
    local component = event.component
    -- Adding the Entity to Entitylist
    if not self.entityLists[component] then self.entityLists[component] = {} end
    self.entityLists[component][entity.id] = entity
    -- Adding the Entity to the requiring systems
    if self.requirements[component] then
        for index, system in pairs(self.requirements[component]) do
            self:checkRequirements(entity, system)
        end
    end
end

function Engine:getMaster()
    if self.rootEntity ~= nil then
        return self.rootEntity
    end
end

-- Returns an Entitylist for a specific component. If the Entitylist doesn't exist yet it'll be created and returned.
function Engine:getEntityList(component)
    if not self.entityLists[component] then self.entityLists[component] = {} end
    return self.entityLists[component]
end

function Engine:checkRequirements(entity, system)
    local meetsrequirements = true
    local category = nil
    for index, req in pairs(system.requires()) do
        if type(req) == "string" then
            if not entity.components[req] then
                meetsrequirements = false
                break
            end
        elseif type(req) == "table" then
            meetsrequirements = true
            for index2, req2 in pairs(req) do
                if not entity.components[req2] then
                    meetsrequirements = false
                    break
                end
            end
            if meetsrequirements == true then
                category = index 
                system:addEntity(entity, category)
            end
        end
    end
    if meetsrequirements == true and category == nil then
        system:addEntity(entity)
    end
end

