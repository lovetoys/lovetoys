Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.requirements = {}
    self.entityLists = {}

    self.allSystems = {}
    self.logicSystems = {}
    self.drawSystems = {}

    self.freeIds = {}
end

function Engine:addEntity(entity)
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

function Engine:addSystem(system, type)
    -- Adding System to draw or logic table
    if type == "draw" then
        table.insert(self.drawSystems, system)
    elseif type == "logic" then
        table.insert(self.logicSystems, system)
    end
    table.insert(self.allSystems, system)

    -- Registering the systems requirements and saving them in a special table for fast access
    for index, value in pairs(system:getRequiredComponents()) do
        self.requirements[value] = self.requirements[value] or {}
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
            self.entityLists[component][entity.id] = nil
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
        if self.entityLists[component] then
            table.insert(self.entityLists[component], entity)
        else
            self.entityLists[component] = {}
            table.insert(self.entityLists[component], entity)
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
    if self.entityLists[component] then
        return self.entityLists[component]
    else
        self.entityLists[component] = {}
        return self.entityLists[component]
    end
end