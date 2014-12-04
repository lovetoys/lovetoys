# Lovetoys

Lovetoys is a small bundle of helper classes and libraries consisting of 3 packages. The most important one is the Entity Component System which is based on [Richard Lords Introduction](http://www.richardlord.net/blog/what-is-an-entity-framework) to ECS's. If you don't have any idea what this entity component stuff is all about, click that link and give it a read! It's totally worth it!

Besides the Entity Component System the Lovetoys also contain an event manager for handling keypresses etc. and a collision manager for easier management of Löve2D collisions.

This Software is published under the MIT license. For further information check the LICENSE.md.

The Software is tested and should be stable. If you find any bugs please create an issue and report them. Otherwise feel free to create a pull request :).

## Installation

The best way of installing Lovetoys is creating a submodule and cloning it right into your git repo. 
Another way is to just download the files, especially the lovetoys folder, and copy them to your project folder.  
To import everything just require lovetoys/lovetoys.

For an example on how to use the lovetoys check our [example](https://github.com/Lovetoys/Lovetoys-examples) folder.

The following text describes the different classes the lovetoys provide.

## Entity Component System

### Entity

The Entity is the basic object that is beeing administrated by the engine. It functions merely as a container for components.

#### Entity(parent)
- **parent** - Parent entity

This function returns a new instance of an entity. If a parent entity is given, a reference to this entity will be stored in `self.parent`.
Another reference to the newly created entity will be stored in `parent.children`.  
If there is no parent specified, while the engine got their rootEntity entity enabled, the created entity is automatically added to rootEntity entity's children.

#### Entity:setParent(parent)
- **parent** - Parent entity

This function has to be used, if you want to set a parent after already having the entity added to the engine. This can be used to create classes that are derived from Entity as well.

#### Entity:getParent(parent)

Gets the parent entity. Returns nil if parent not specified.

#### Entity:add(component)
- **component** - (Component) Instance of a component.

Adds a component to this particular entity. 

#### Entity:remove(name)

- **name** (String) - Name of the component class 

Removes a component from this particular entity.  
    
#### Entity:get(Name)

- **name** (String) - Name of the component class  

Returns the component or `nil` if the Entity has no component with the given `name`.

#### Entity:has(Name)

- **name** (String) - Name of the component class  

Returns if the Entity contains this component.  

### Component

This doesn't do anything yet. It will be used for type checks someday.

### System

Systems function as service provider inside of the ECS. The engine manages all Systems and assigns all suitable entities to the respective systems.

There are two types of Systems: "logic" and "draw" Systems. Logic systems perform logic operations, like moving a player and updating physics. Their `update` method is called by `Engine:update()`, which in turn should be called in the `update` function of your game loop.
Draw systems are responsible for rendering your game world on screen. Their `draw` method is called by `Engine:draw()`, which is usually called in the `draw()` function of the game loop.


#### System:requires() return {"Componentname1", "Componentname2", ...} end 

This function defines what kind of entities shall be managed by this System. The function has to be overwritten in every System! The strings inside the returned table define the components a entity has to contain, to be managed by the System. Those entities are accessible in `self.targets`.

If you want to manage different kinds of entities just return a table that looks like this:

`return {name1 = {"Componentname1", "Componentname2"}, name2 = {"Componentname3", "Componentname4"}}`

The different entities are now accessible under `system.targets[name1]` and `system.targets[name2]`.  
An entity can be contained by the same system multiple times in different target pools if they match the varying component constellations.


#### System:update(dt)

- **dt** (Number) - The time passed since the last update, in seconds.

If you implement this function in your system the engine detects it automatically and it will be called in the update loop.

#### System:draw() 

If you implement this function in your system the engine detects it automatically and it will be called in the draw loop.

#### An example for a custom system

    CustomSystem = class("CustomSystem", System)

    function CustomSystem:update(dt)
        for key, entity in pairs(self.targets) do
            local foo =  entity:get("Component1").foo
            entity:get("Component2").bar = foo
        end
    end

    function CustomSystem:requires()
        return {"Component1", "Component2"}
    end

### Engine

The engine is the most important part of our framework and the most frequently used interface. It contains all systems, entities, requirements and entitylists and manages them for you.

#### Engine(rootEntity)

- **rootEntity** (Boolean)

Creates a new engine object. If the parameter is `true` a new rootEntity will be created inside the engine. This entity will be the parent of all entities, as long as they don't have a particular parent specified.

#### Engine:getMaster()

Returns the rootEntity entity, if it has been created during the engine's creation.

#### Engine:addSystem(system, type)

- **system** (System) - Instance of the system to be added.  
- **type** (String) - Should be either "draw", "logic" or nil  

Adds a system of the particular type to the engine. Depending on `type`, either `system:draw()` or `system:update(dt)` is going to be called, in this case you don't need to add a type.
The systems will be updated in the order they've been added.  
If a system implements both draw and update functions, you will need to specify the type and add it twice to the engine. Once to draw and once to update. Otherwise the engine doesn't know which priority the system should get.


#### Engine:stop(system)

- **system** (String) - the name of the system

If you want a system to stop, call this function. It's draw/update function won't be called.

#### Engine:start(system)

- **system** (String) 
    the name of the system

Call this to start a stopped system.


#### Engine:addEntity(entity)

- **entity** (Entity) - Instance of the Entity to be added

Adds an entity to the engine and sends it to all systems that are interested in its component constellation.

#### Engine:removeEntity(entity, removeChildren)
- **entity** - (Entity) - Instance of the Entity to be removed
- **removeChildren** - (Boolean) 

Removes the particular entity from the engine and all systems.  
Depending on `removeChildren` all Children are going to deleted recursivly as well.

#### Engine:getEntityList(component)

- **component** (String) - Class name of the component   

Returns a list with all entities that contain this particular component.

#### Engine:update(dt)

- **dt** (Number) - Time since the last update, in seconds

Updates all logic systems.

#### Engine:draw()

Updates all draw systems.

#### Example

For a more detailed and commented version with collisions and some other examples check the [example main.lua](https://github.com/Lovetoys/Lovetoys-examples/blob/rootEntity/main.lua).

    -- Importing lovetoys
    require("lovetoys/engine")

    function love.load()
        engine = Engine()
        world = love.physics.newWorld(0, 9.81*80, true)
        world:setCallbacks(beginContact, endContact)
        eventmanager = EventManager()
    end

    function love.update(dt)
        -- Engine update function
        engine:update(dt)
        world:update(dt)
    end

    function love.draw()
        -- Engine draw function
        engine:draw()
    end 

    function love.keypressed(key, isrepeat)
        eventmanager:fireEvent(KeyPressed(key, isrepeat))
    end

    function love.mousepressed(x, y, button)
        eventmanager:fireEvent(MousePressed(x, y, button))
    end

## Eventmanager

This class is a simple eventmanager for sending events to their respective listeners.

#### EventManager:addListener(eventName, listener)

- **eventName** (String) - Name of the event-class to be added 

- **listener** (Listener) - A table containing information about the listener function. The first entry should be a value that will be passed as `self` to the called function, while the second entry should be the function itself.

Adds a function that is listening to the Event.  
An example for adding a Listener: `EventManager:addListener("EventName", {table, table.func})`.  
We need to do this so we can work with `self` as we are used to, as lua doesn't provide a native class implementation.

#### EventManager:removeListener(eventName, listener)

- **eventName** (String) - Name of the event-class  

- **listener** (String) - Name of the listener to be deleted  

Removes a listener from this particular Event.

#### EventManager:fireEvent(event)

- **event** (Event) - Instance of the event  

This function pipes the event through to every listener that is registered to the class-name of the event and triggers `listener:fireEvent(event)`.

## CollisionManager

This helperclass helps to avoid code redundancy and to create neater code.  
Our collisionmanager works in association with our eventmanager as it expects to get a event with the colliding entities.  
The required event is already contained and you can find an example of how to use it in our [example](https://github.com/Lovetoys/Lovetoys-example) folder.

#### CollisionManager:addCollisionAction(component1, component2, object)

- **component1**, **component2** (String) Names of the required components  
- **object** (Collision) - Instance of the collision class.  

Adds a new collision to the manager. If two entities, who satisfy the requirements, collide, the `collision:action(entities)` function will be triggered.  
The entity that contains component1 will be given to you inside `entities.entity1` and the entity that contains component2 will be inside `entities.entity2`.  

If you want a entity to collide with any other entity, just name one of the required components "Everything".

## Class

A simple class implementation for OOP. 

#### How to create a class

    Foo = class("Foo")

    -- The constructor of this class
    function Foo:__init(parameter)
        self.bar = parameter
    end

If you want to create a object of this class just call `Foo(parameter)` and it will return a object after calling the constructor.  

If you want to create a class that inherits from a superclass you have to pass a superclass:  

    Foo = class("Foo", Superclass)

All superclass constructors will now be called on new Foo instances.
To create a new instance you now just have to call `Foo()` e.g.

    NewInstance = Foo()


* * *

Copyright &copy; 2013-2014 Arne Beer and Rafael Epplée

Published under the MIT License.

For further information check `license.txt`.
