snippet:  function class(name, super)
    -- main metadata
    local cls = {}

    -- copy the members of the supercls
    if super then
        for k,v in pairs(super) do
            cls[k] = v
        end
    end

    cls.__name = name
    cls.__super = super

    -- when the cls object is being called,
    -- create a new object containing the cls'
    -- members, calling its __init with the given
    -- params
    cls = setmetatable(cls, {__call = function(c, ...)
        local obj = {}
        for k,v in pairs(cls) do
            obj[k] = v
        end
        superInit(obj)
        if obj.__init then obj:__init(...) end
        return obj
    end})

    return cls
end

function superInit(object, super)
    if super then
        if getSuper(super) then
            superInit(object, getSuper(super))
        end
        if super.__init then
            super.__init(object)
        end
    elseif getSuper(object) then
        superInit(object, getSuper(object))
    end
end

function getSuper(object)
    if object.__super then
        return object.__super
    end
end

function getName(object)
    return object.__name
end

-- Collection of utilities for handling Components
Component = {}

Component.all = {}

-- Create a Component class with the specified name and fields
-- which will automatically get a constructor accepting the fields as arguments
function Component.create(name, fields, defaults)
	local component = class(name)

	if fields then
    defaults = defaults or {}
		component.__init = function(self, ...)
      local args = {...}
			for index, field in ipairs(fields) do
				self[field] = args[index] or defaults[field]
			end
		end
	end

	Component.register(component)

	return component
end

-- Register a Component to make it available to Component.load
function Component.register(componentClass)
	Component.all[componentClass.__name] = componentClass
end

-- Load multiple components and populate the calling functions namespace with them
-- This should only be called from the top level of a file!
function Component.load(names)
  local env = {}
  setmetatable(env, {__index = _G})
  setfenv(2, env)

  for _, name in pairs(names) do
    env[name] = Component.all[name]
  end
end

Entity = class("Entity")

function Entity:__init(parent, name)
    self.components = {}
    self.eventManager = nil
    self.alive = false
    if parent then
        self:setParent(parent)
    else
        parent = nil
    end
    self.name = name
    self.children = {}
end

-- Sets the entities component of this type to the given component.
-- An entity can only have one Component of each type.
function Entity:add(component)
    if self.components[component.__name] then 
        if lovetoyDebug then
            print("Trying to add Component '" .. component.__name .. "', but it's already existing. Please use Entity:set to overwrite a component in an entity.")
        end
    else
        self.components[component.__name] = component
        if self.eventManager then
            self.eventManager:fireEvent(ComponentAdded(self, component.__name))
        end
    end
end

function Entity:set(component)
    if self.components[component.__name] == nil then
        self:add(component)
    else
        self.components[component.__name] = component
    end
end

function Entity:addMultiple(componentList)
    for _, component in  pairs(componentList) do
        self:add(component)
    end
end

-- Removes a component from the entity.
function Entity:remove(name)
    if self.components[name] then
        self.components[name] = nil
    else
        if lovetoyDebug then
            print("Trying to remove unexisting component " .. name .. " from Entity. Please fix this")
        end
    end
    if self.eventManager then
        self.eventManager:fireEvent(ComponentRemoved(self, name))
    end
end

function Entity:setParent(parent)
    if self.parent then self.parent.children[self.id] = nil end
    self.parent = parent
    self:registerAsChild()
end

function Entity:getParent(parent)
    return self.parent
end

function Entity:registerAsChild()
    if self.id then self.parent.children[self.id] = self end
end

function Entity:get(name)
    return self.components[name]
end

function Entity:has(name)
    return not not self.components[name] 
end

function Entity:getComponents()
    return self.components
end

function table.firstElement(list)
    for index, value in pairs(list) do
        return value
    end
end

System = class("System")

function System:__init()
    -- Liste aller Entities, die die RequiredComponents dieses Systems haben
    self.targets = {}
    self.active = true
end

function System:requires() return {} end

function System:addEntity(entity, category)
    -- If there are multiple requirement lists, the added entities will 
    -- be added to their respetive list. 
    if category then
        self.targets[category][entity.id] = entity
    else
    -- Otherwise they'll be added to the normal self.targets list
        self.targets[entity.id] = entity
    end
end

function System:removeEntity(entity, component)
    if table.firstElement(self.targets) then
        if table.firstElement(self.targets).__name then
            self.targets[entity.id] = nil
        else
            -- Removing entities from their respective category target list.
            for index, _ in pairs(self.targets) do
                if component then
                    for _, req in pairs(self:requires()[index]) do
                        if req == component then
                            self.targets[index][entity.id] = nil
                            break
                        end
                    end
                else
                    self.targets[index][entity.id] = nil
                end
            end
        end
    end
end

-- TODO: Refactorn!!!! Entweder universal anwendbar machen oder
-- weghauen. Was passiert bei Component constallations in :requires()??
function System:pickRequiredComponents(entity)
    local components = {}
    for i, componentName in pairs(self:requires()) do
        table.insert(components, entity:get(componentName))
    end
    return unpack(components)
end

EventManager = class("EventManager")

function EventManager:__init()
    self.eventListeners = {}
end

-- Adding an eventlistener to a specific event
function EventManager:addListener(eventName, listener, listenerFunction)
    -- If there's no list for this event, we create a new one
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    -- Backward compability. This'll be removed in some time
    if not listenerFunction then
        for key, registeredListener in pairs(self.eventListeners[eventName]) do
            if registeredListener[1].__name == listener[1].__name then
                if lovetoyDebug then
                    print("EventListener already existing. Aborting")
                end
                return
            end
        end
        table.insert(self.eventListeners[eventName], listener)
    else
        for key, registeredListener in pairs(self.eventListeners[eventName]) do
            if registeredListener[1].__name == listener.__name then
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
                print('Eventmanager: Second parameter has to be a function! Pls check ' .. listener.__name)
            end
        end
    end
end

-- Removing an eventlistener from an event
function EventManager:removeListener(eventName, listener)
    if self.eventListeners[eventName] then
        for key, registeredListener in pairs(self.eventListeners[eventName]) do
            if registeredListener[1].__name == listener then
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
    if self.eventListeners[event.__name] then
        for _,listener in pairs(self.eventListeners[event.__name]) do
            listener[2](listener[1], event)
        end
    end
end

ComponentAdded = class("ComponentAdded")

function ComponentAdded:__init(entity, component)
    self.entity = entity
    self.component = component
end

ComponentRemoved = class("ComponentRemoved")

function ComponentRemoved:__init(entity, component)
    self.entity = entity
    self.component = component
end

function table.firstElement(list)
    for index, value in pairs(list) do
        return value
    end
end

Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.rootEntity = Entity()
    self.singleRequirements = {}
    self.allRequirements = {}
    self.entityLists = {}
    self.eventManager = EventManager()
    self.initializer = {}

    self.systems = {}
    self.systemRegistry= {}
    self.systems["all"] = {}
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

    -- Calling initializer
    for component, func in pairs(self.initializer) do
        if entity:has(component) then
            func(entity)
        end
    end

    for index, component in pairs(entity.components) do
        -- Adding Entity to specific Entitylist
        if not self.entityLists[component.__name] then self.entityLists[component.__name] = {} end
        self.entityLists[component.__name][entity.id] = entity

        -- Adding Entity to System if all requirements are granted
        if self.singleRequirements[component.__name] then
            for index2, system in pairs(self.singleRequirements[component.__name]) do
                self:checkRequirements(entity, system)
            end
        end
    end
end 

function Engine:removeEntity(entity, removeChildren, newParent)
    -- Removing the Entity from all Systems and engine
    for _, component in pairs(entity.components) do
        if self.singleRequirements[component.__name] then
            for _, system in pairs(self.singleRequirements[component.__name]) do
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
        for index, child in pairs(entity.parent.children) do
            entity.parent.children[entity.id] = nil
        end
        -- Setting status of entity to dead. This is for other systems, which still got a hard reference on this
        self.entities[entity.id].alive = false
        -- Removing entity from engine
        self.entities[entity.id] = nil
    else
        if lovetoyDebug then
            print("Trying to remove non existent entity from engine.")
            print("Entity id: " .. entity.id)
            print("Entity's components:")
            for index, component in pairs(entity.components) do
                print(index)
            end
        end
    end
end

function Engine:addSystem(system, typ)

    -- Check if system has both function without specified type
    if system.draw and system.update and not typ then
        if lovetoyDebug then
            print("Lovetoys: Trying to add " .. system.__name .. ", which has an update and a draw function, without specifying typ. Aborting")
        end
        return
    end
    -- Adding System to engine system reference table
    if not (self.systemRegistry[system.__name]) then 
        self:registerSystem(system)
    -- This triggers if the system doesn't have update and draw and it's already existing.
    elseif not (system.update and system.draw) then
        if self.systemRegistry[system.__name] then
            if lovetoyDebug then
                print("Lovetoys: " .. system.__name .. " already exists. Aborting")
            end
            return
        end
    end

    -- Adding System to draw table
    if system.draw and (not typ or typ == "draw") then
        for _, registeredSystem in pairs(self.systems["draw"]) do
            if registeredSystem.__name == system.__name then
                if lovetoyDebug then
                    print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                end
                return
            end
        end
        table.insert(self.systems["draw"], system)
    -- Adding System to update table
    elseif system.update and (not typ or typ == "update") then
        for _, registeredSystem in pairs(self.systems["update"]) do
            if registeredSystem.__name == system.__name then
                if lovetoyDebug then
                    print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                end
                return
            end
        end
        table.insert(self.systems["update"], system)
    end

    -- Checks if some of the already existing entities match the required components.
    for index, entity in pairs(self.entities) do
        self:checkRequirements(entity, system)
    end
    return system
end

function Engine:registerSystem(system)
    self.systemRegistry[system.__name] = system
    table.insert(self.systems["all"], system)
    -- Registering in case system:requires returns a table of strings
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

    -- Registering in case its a table of tables which contain strings
    if table.firstElement(system:requires()) and type(table.firstElement(system:requires())) == "table" then
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
            system.targets[index] = {}
        end
    end
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

function Engine:addInitializer(name, func)
    self.initializer[name] = func
end

function Engine:removeInitializer(name)
    self.initializer[name] = nil
end

function Engine:draw()
    for index, system in ipairs(self.systems["draw"]) do
        if system.active then
            system:draw()
        end
    end
end

function Engine:componentRemoved(event)
    local entity = event.entity
    local component = event.component

    -- Removing Entity from Entitylists
    self.entityLists[component][entity.id] = nil

    -- Removing Entity from old systems
    if self.allRequirements[component] then
        for index, system in pairs(self.allRequirements[component]) do 
            system:removeEntity(entity, component)
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
        for index, system in pairs(self.allRequirements[component]) do
            self:checkRequirements(entity, system)
        end
    end

    -- Calling Initializer
    if self.initializer[event.component] then
        self.initializer[event.component](event.entity)
    end
end

function Engine:getRootEntity()
    if self.rootEntity ~= nil then
        return self.rootEntity
    end
end

-- Returns an Entitylist for a specific component. If the Entitylist doesn't exist yet it'll be created and returned.
function Engine:getEntitiesWithComponent(component)
    if not self.entityLists[component] then self.entityLists[component] = {} end
    return self.entityLists[component]
end

function Engine:checkRequirements(entity, system)
    local meetsrequirements = true
    local category = nil
    for index, req in pairs(system:requires()) do
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
function class(a,b)local c={}if b then for d,e in pairs(b)do c[d]=e end end;c.__name=a;c.__super=b;c=setmetatable(c,{__call=function(f,...)local g={}for d,e in pairs(c)do g[d]=e end;superInit(g)if g.__init then g:__init(...)end;return g end})return c end;function superInit(h,b)if b then if getSuper(b)then superInit(h,getSuper(b))end;if b.__init then b.__init(h)end elseif getSuper(h)then superInit(h,getSuper(h))end end;function getSuper(h)if h.__super then return h.__super end end;function getName(h)return h.__name end;Component={}Component.all={}function Component.create(a,i,j)local k=class(a)if i then j=j or{}k.__init=function(l,...)local m={...}for n,o in ipairs(i)do l[o]=m[n]or j[o]end end end;Component.register(k)return k end;function Component.register(p)Component.all[p.__name]=p end;function Component.load(q)local r={}setmetatable(r,{__index=_G})setfenv(2,r)for s,a in pairs(q)do r[a]=Component.all[a]end end;Entity=class("Entity")function Entity:__init(t,a)l.components={}l.eventManager=nil;l.alive=false;if t then l:setParent(t)else t=nil end;l.name=a;l.children={}end;function Entity:add(k)if l.components[k.__name]then if lovetoyDebug then print("Trying to add Component '"..k.__name.."', but it's already existing. Please use Entity:set to overwrite a component in an entity.")end else l.components[k.__name]=k;if l.eventManager then l.eventManager:fireEvent(ComponentAdded(l,k.__name))end end end;function Entity:set(k)if l.components[k.__name]==nil then l:add(k)else l.components[k.__name]=k end end;function Entity:addMultiple(u)for s,k in pairs(u)do l:add(k)end end;function Entity:remove(a)if l.components[a]then l.components[a]=nil else if lovetoyDebug then print("Trying to remove unexisting component "..a.." from Entity. Please fix this")end end;if l.eventManager then l.eventManager:fireEvent(ComponentRemoved(l,a))end end;function Entity:setParent(t)if l.parent then l.parent.children[l.id]=nil end;l.parent=t;l:registerAsChild()end;function Entity:getParent(t)return l.parent end;function Entity:registerAsChild()if l.id then l.parent.children[l.id]=l end end;function Entity:get(a)return l.components[a]end;function Entity:has(a)return not not l.components[a]end;function Entity:getComponents()return l.components end;function table.firstElement(v)for n,w in pairs(v)do return w end end;System=class("System")function System:__init()l.targets={}l.active=true end;function System:requires()return{}end;function System:addEntity(x,y)if y then l.targets[y][x.id]=x else l.targets[x.id]=x end end;function System:removeEntity(x,k)if table.firstElement(l.targets)then if table.firstElement(l.targets).__name then l.targets[x.id]=nil else for n,s in pairs(l.targets)do if k then for s,z in pairs(l:requires()[n])do if z==k then l.targets[n][x.id]=nil;break end end else l.targets[n][x.id]=nil end end end end end;function System:pickRequiredComponents(x)local A={}for B,C in pairs(l:requires())do table.insert(A,x:get(C))end;return unpack(A)end;EventManager=class("EventManager")function EventManager:__init()l.eventListeners={}end;function EventManager:addListener(D,E,F)if not l.eventListeners[D]then l.eventListeners[D]={}end;if not F then for G,H in pairs(l.eventListeners[D])do if H[1].__name==E[1].__name then if lovetoyDebug then print("EventListener already existing. Aborting")end;return end end;table.insert(l.eventListeners[D],E)else for G,H in pairs(l.eventListeners[D])do if H[1].__name==E.__name then if lovetoyDebug then print("EventListener already existing. Aborting")end;return end end;if type(F)=='function'then table.insert(l.eventListeners[D],{E,F})else if lovetoyDebug then print('Eventmanager: Second parameter has to be a function! Pls check '..E.__name)end end end end;function EventManager:removeListener(D,E)if l.eventListeners[D]then for G,H in pairs(l.eventListeners[D])do if H[1].__name==E then table.remove(l.eventListeners[D],G)return end end;if lovetoyDebug then print("Listener to be deleted is not existing.")end end end;function EventManager:fireEvent(I)if l.eventListeners[I.__name]then for s,E in pairs(l.eventListeners[I.__name])do E[2](E[1],I)end end end;ComponentAdded=class("ComponentAdded")function ComponentAdded:__init(x,k)l.entity=x;l.component=k end;ComponentRemoved=class("ComponentRemoved")function ComponentRemoved:__init(x,k)l.entity=x;l.component=k end;function table.firstElement(v)for n,w in pairs(v)do return w end end;Engine=class("Engine")function Engine:__init()l.entities={}l.rootEntity=Entity()l.singleRequirements={}l.allRequirements={}l.entityLists={}l.eventManager=EventManager()l.initializer={}l.systems={}l.systemRegistry={}l.systems["all"]={}l.systems["update"]={}l.systems["draw"]={}l.eventManager:addListener("ComponentRemoved",l,l.componentRemoved)l.eventManager:addListener("ComponentAdded",l,l.componentAdded)end;function Engine:addEntity(x)x.eventManager=l.eventManager;local J=#l.entities+1;x.id=J;l.entities[x.id]=x;if x.parent==nil then x:setParent(l.rootEntity)end;x:registerAsChild()for k,K in pairs(l.initializer)do if x:has(k)then K(x)end end;for n,k in pairs(x.components)do if not l.entityLists[k.__name]then l.entityLists[k.__name]={}end;l.entityLists[k.__name][x.id]=x;if l.singleRequirements[k.__name]then for L,M in pairs(l.singleRequirements[k.__name])do l:checkRequirements(x,M)end end end end;function Engine:removeEntity(x,N,O)for s,k in pairs(x.components)do if l.singleRequirements[k.__name]then for s,M in pairs(l.singleRequirements[k.__name])do M:removeEntity(x)end end end;for n,k in pairs(x.components)do l.entityLists[k.__name][x.id]=nil end;if l.entities[x.id]then if N then for s,P in pairs(x.children)do l:removeEntity(P,true)end else for s,P in pairs(x.children)do if O then P:setParent(O)else P:setParent(l.rootEntity)end;x:registerAsChild()end end;for n,P in pairs(x.parent.children)do x.parent.children[x.id]=nil end;l.entities[x.id].alive=false;l.entities[x.id]=nil else if lovetoyDebug then print("Trying to remove non existent entity from engine.")print("Entity id: "..x.id)print("Entity's components:")for n,k in pairs(x.components)do print(n)end end end end;function Engine:addSystem(M,Q)if M.draw and M.update and not Q then if lovetoyDebug then print("Lovetoys: Trying to add "..M.__name..", which has an update and a draw function, without specifying typ. Aborting")end;return end;if not l.systemRegistry[M.__name]then l:registerSystem(M)elseif not(M.update and M.draw)then if l.systemRegistry[M.__name]then if lovetoyDebug then print("Lovetoys: "..M.__name.." already exists. Aborting")end;return end end;if M.draw and not Q or Q=="draw"then for s,R in pairs(l.systems["draw"])do if R.__name==M.__name then if lovetoyDebug then print("Lovetoys: "..M.__name.." already exists. Aborting")end;return end end;table.insert(l.systems["draw"],M)elseif M.update and not Q or Q=="update"then for s,R in pairs(l.systems["update"])do if R.__name==M.__name then if lovetoyDebug then print("Lovetoys: "..M.__name.." already exists. Aborting")end;return end end;table.insert(l.systems["update"],M)end;for n,x in pairs(l.entities)do l:checkRequirements(x,M)end;return M end;function Engine:registerSystem(M)l.systemRegistry[M.__name]=M;table.insert(l.systems["all"],M)if M:requires()[1]and type(M:requires()[1])=="string"then for n,z in pairs(M:requires())do if n==1 then l.singleRequirements[z]=l.singleRequirements[z]or{}table.insert(l.singleRequirements[z],M)end;l.allRequirements[z]=l.allRequirements[z]or{}table.insert(l.allRequirements[z],M)end end;if table.firstElement(M:requires())and type(table.firstElement(M:requires()))=="table"then for n,u in pairs(M:requires())do local k=u[1]l.singleRequirements[k]=l.singleRequirements[k]or{}table.insert(l.singleRequirements[k],M)for s,z in pairs(u)do l.allRequirements[z]=l.allRequirements[z]or{}local S=false;for s,R in pairs(l.allRequirements[z])do if R==M then S=true;break end end;if not S then table.insert(l.allRequirements[z],M)end end;M.targets[n]={}end end end;function Engine:stopSystem(a)for n,M in pairs(l.systems["all"])do if a==M.__name then M.active=false end end end;function Engine:startSystem(a)for n,M in pairs(l.systems["all"])do if a==M.__name then M.active=true end end end;function Engine:toggleSystem(a)for n,M in pairs(l.systems["all"])do if a==M.__name then M.active=not M.active end end end;function Engine:update(T)for n,M in ipairs(l.systems["update"])do if M.active then M:update(T)end end end;function Engine:addInitializer(a,K)l.initializer[a]=K end;function Engine:removeInitializer(a)l.initializer[a]=nil end;function Engine:draw()for n,M in ipairs(l.systems["draw"])do if M.active then M:draw()end end end;function Engine:componentRemoved(I)local x=I.entity;local k=I.component;l.entityLists[k][x.id]=nil;if l.allRequirements[k]then for n,M in pairs(l.allRequirements[k])do M:removeEntity(x,k)end end end;function Engine:componentAdded(I)local x=I.entity;local k=I.component;if not l.entityLists[k]then l.entityLists[k]={}end;l.entityLists[k][x.id]=x;if l.allRequirements[k]then for n,M in pairs(l.allRequirements[k])do l:checkRequirements(x,M)end end;if l.initializer[I.component]then l.initializer[I.component](I.entity)end end;function Engine:getRootEntity()if l.rootEntity~=nil then return l.rootEntity end end;function Engine:getEntitiesWithComponent(k)if not l.entityLists[k]then l.entityLists[k]={}end;return l.entityLists[k]end;function Engine:checkRequirements(x,M)local U=true;local y=nil;for n,z in pairs(M:requires())do if type(z)=="string"then if not x.components[z]then U=false;break end elseif type(z)=="table"then U=true;for L,V in pairs(z)do if not x.components[V]then U=false;break end end;if U==true then y=n;M:addEntity(x,y)end end end;if U==true and y==nil then M:addEntity(x)end end
