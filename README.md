# Lovetoys

Lovetoys is an Entity Component System framework for the LÖVE 2D game engine.
It is loosely based on [Richard Lords Introduction](http://www.richardlord.net/blog/what-is-an-entity-framework) to ECS's. If you don't have any idea what this entity component stuff is all about, click that link and give it a read! It's totally worth it!

Lovetoys is a full-featured game development framework, not only providing the core parts like Entity, Component and System classes but also containing a Publish-Subscribe messaging system as well as an Entity Tree, enabling you to build even complex games easily and in an organized way.

The Software is tested and used in multiple games and is stable. If you find any bugs please create an issue and report them. Or just create a pull request :).

## Installation

The best way of installing Lovetoys is by creating a submodule and cloning it right into your git repo.
Another way is to just download the files, especially the `src` folder, and copy them to your project folder.
To import everything just `require('lovetoys/lovetoys')`.

For an example on how to use the lovetoys have a look at our [example](https://github.com/Lovetoys/Lovetoys-examples) repository.

## Entity Component System

### Entity

The Entity is the basic object that is beeing administrated by the engine. It functions merely as a container for components.

#### Entity(parent)
- **parent** (Entity) - Parent entity

This function returns a new instance of an entity. If a parent entity is given, a reference to this entity will be stored in `self.parent`.
Another reference to the newly created entity will be stored in `parent.children`.
If the entity has no parent when being added to the engine, the root entity will be set as its parent.

#### Entity:setParent(parent)
- **parent** (Entity) - Parent entity

This function has to be used, if you want to set a parent after already having the entity added to the engine. This can be used to create classes that are derived from Entity as well.

#### Entity:getParent()

Gets the parent entity.

#### Entity:add(component)
- **component** - (Component) Instance of a component.

Adds a component to this particular entity.

#### Entity:addMultiple(components)
- **components** - (List) A list containing instances of components.

Adds multiple components to the entity at once.

#### Entity:set(component)
- **component** - (Component) Instance of a component.

Adds the component to this particular entity. If there already exists a component of this type the previous component will be overwritten.

#### Entity:remove(name)

- **name** (String) - Name of the component class

Removes a component from this particular entity.

#### Entity:has(Name)

- **name** (String) - Name of the component class

Returns boolean depending on if the component is contained by the entity.


#### Entity:get(Name)

- **name** (String) - Name of the component class

Returns the component or `nil` if the Entity has no component with the given `name`.

#### Entity:getComponents()

Returns the list that contains all components.

### Component

This doesn't do anything yet. It will be used for type checks someday.

### System

Systems function as service provider inside of the ECS. The engine manages all Systems and assigns all suitable entities to the respective systems.

All custom systems have to be derived from the `System` class. An example how to do this can be found below.

There are two types of Systems: "logic" and "draw" Systems. Logic systems perform logic operations, like moving a player and updating physics. Their `update` method is called by `Engine:update()`, which in turn should be called in the `update` function of your game loop.
Draw systems are responsible for rendering your game world on screen. Their `draw` method is called by `Engine:draw()`, which is usually called in the `draw()` function of the game loop.

#### System:requires() return {"Componentname1", "Componentname2", ...} end

This function defines what kind of entities shall be managed by this System. The function has to be overwritten in every System or it won't get any entities! The strings inside the returned table define the components a entity has to contain, to be managed by the System. Those entities are accessible in `self.targets`.

If you want to manage different kinds of entities just return a table that looks like this:

`return {name1 = {"Componentname1", "Componentname2"}, name2 = {"Componentname3", "Componentname4"}}`

The different entities are now accessible under `system.targets.name1` and `system.targets.name2`.
An entity can be contained by the same system multiple times in different target pools if it matches the varying component constellations.

#### System:update(dt)

- **dt** (Number) - The time passed since the last update, in seconds.

This function is going to be called by the engine every tick.


#### System:draw()

This function is going to be called by the engine every draw.

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

#### Engine()

Creates a new engine object. Every engine containes a rootEntity which becomes parent of all entities, as long as they don't have a particular parent specified.

#### Engine:getRootEntity()

Returns the rootEntity entity, to get its children or add/remove components.

#### Engine:addSystem(system, type)

- **system** (System) - Instance of the system to be added.
- **type** (String) - Should be either "draw", "logic" or unspecified

This function registers the system in the engine. The systems' functions will be called in the order they've been added. As long as the system implements either the `update` or the `draw` function, type doesn't have to be specified.
If a system implements both, draw and update function, you will need to specify the type and add it twice to the engine. Once to draw and once to update. Otherwise the engine doesn't know which priority the system should get.

#### Engine:stop(system)

- **system** (String) - the name of the system

If you want a system to stop, just call this function. It's draw/update function won't be called anymore, until it's beeing started again.

#### Engine:start(system)

- **system** (String)
    the name of the system

Call this to start a stopped system.

#### Engine:toggleSystem(system)

- **system** (String)
    the name of the system

Toggle the specified system.

#### Engine:addEntity(entity)

- **entity** (Entity) - Instance of the Entity to be added

Adds an entity to the engine and sends it to all systems that are interested in its component constellation.

#### Engine:removeEntity(entity, removeChildren, newParent)
- **entity** - (Entity) - Instance of the Entity to be removed
- **removeChildren** - (Boolean) Default is false
- **newParent** - (Entity) - Instance of another entity, which should become the new Parent

Removes the particular entity from the engine and all systems.
Depending on `removeChildren` all Children are going to deleted recursivly as well.
If there is a new Parent defined, this entity becomes the new Parent of all children, otherwise they become children of `engine.rootEntity`.

#### Engine:getEntitiesWithComponent(component)

- **component** (String) - Class name of the component

Returns a list with all entities that contain this particular component.

#### Engine:update(dt)

- **dt** (Number) - Time since the last update, in seconds

Updates all logic systems.

#### Engine:draw()

Updates all draw systems.

#### Engine:addInitializer(name, func)
- **name** - (String) - Name of the component
- **func** - (function)

Every time you want to call a function on an entity as soon as it has been added to the engine you want to use Initializer.
Just pass the name of a componentname and a function and for every entity that contains such a component `func(entity)` will be called.

#### Engine:removeInitializer(name)
- **name** - (String) - Name of the component

The initializer that is registered to this component will be deleted.

#### Example

For a more detailed and commented version with collisions and some other examples check the [main.lua file of the lovetoys example game](https://github.com/lovetoys/example/blob/master/main.lua).

    -- Importing lovetoys
    require("lib/lovetoys/lovetoys")

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

#### EventManager:addListener(eventName, listener, listenerFunction)

- **eventName** (String) - Name of the event-class to be added

- **listener** (Listener) - The first entry is the table/class that will is supposed to be passed as `self` to the called function.

- **listenerFunction** (Function) - The function that should be called.

Adds a function that is listening to the Event.
An example for adding a Listener: `EventManager:addListener("EventName", listener, listener.func)`. The resulting function call will be `func(table, event)`.
We need to do this so we can work with `self` as we are used to, as lua doesn't provide a native class implementation.

#### EventManager:removeListener(eventName, listener)

- **eventName** (String) - Name of the event-class

- **listener** (String) - Name of the listener to be deleted

Removes a listener from this particular Event.

#### EventManager:fireEvent(event)

- **event** (Event) - Instance of the event

This function pipes the event through to every listener that is registered to the class-name of the event and triggers `listener:fireEvent(event)`.


## CollisionManager

`CollisionManager` was a class that helped with specifying callbacks for certain collision events.
We removed it from the Lovetoys. It performed too poorly and we felt it only bloated the framework while not being needed in many cases.

## Class

We use our own small class implementation for OOP.

You can create a class as follows:

    Foo = class("Foo")

    -- The constructor of a class is specified by the __init method
    function Foo:__init(parameter)
        self.bar = parameter
    end

If you want to create a object of this class just call `Foo(parameter)` and it will return a object after calling the constructor.

If you want to create a class that inherits from a superclass you have to pass a superclass:

    Foo = class("Foo", Superclass)

All superclass constructors will now be called on new Foo instances.
To create a new instance you now just have to call `Foo()` e.g.

    NewInstance = Foo()

## Testing

You can find the tests in the `spec` folder. They are defined using the [busted](http://olivinelabs.com/busted) test framework.

To run the suite, install busted and simply execute `busted` in the lovetoys directory.

* * *

Copyright &copy; 2013-2014 Arne Beer and Rafael Epplée

This Software is published under the MIT License.

For further information check `LICENSE.md`.


