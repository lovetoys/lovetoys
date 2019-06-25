<div align="center">
  <a href="https://github.com/lovetoys/lovetoys">
    <img width="150" src="http://cdn.rawgit.com/lovetoys/lovetoys/bc73d45634b1220746d1afd618fb1372e42fc096/logo_small.svg" />
  </a>
</div>
<h1 align="center">lövetoys</h1>

[![GitHub release](https://img.shields.io/github/release/lovetoys/lovetoys.svg?maxAge=2592000)](https://github.com/lovetoys/lovetoys/releases/latest)
[![Build Status](https://travis-ci.org/lovetoys/lovetoys.svg?branch=master)](https://travis-ci.org/lovetoys/lovetoys) [![Coverage Status](https://coveralls.io/repos/github/lovetoys/lovetoys/badge.svg?branch=master)](https://coveralls.io/github/lovetoys/lovetoys?branch=master)


lovetoys is an Entity Component System framework for game development with lua. Originally written for the LÖVE 2D game engine, it is actually compatible with pretty much any game that uses lua!
It is inspired by [Richard Lords Introduction](http://www.richardlord.net/blog/what-is-an-entity-framework) to ECS. If you don't have any idea what this entity component stuff is all about, click that link and give it a read! It's totally worth it!

lovetoys is a full-featured game development framework, not only providing the core parts like Entity, Component and System classes but also a Publish-Subscribe messaging system as well as a Scene Graph, enabling you to build even complex games easily and in a structured way.

Though we have not reached version 1.0 yet, the software is well-tested, used in multiple games and considered stable. If you happen to find any bugs, please create an issue and report them. Or, if you're feeling adventurous, create a pull request :)

## Installation

The recommended way of installing lovetoys is by creating a submodule and cloning it right into your git repo.
Another way is to just download a [tarball](https://github.com/lovetoys/lovetoys/releases) and copy the files into your project folder.
We also provide a luarocks package. To use this with LÖVE, check out [loverocks](https://github.com/Alloyed/loverocks).

To require lovetoys and initialize it with the default options, use the following:

```lua
local lovetoys = require('lovetoys')
lovetoys.initialize()
```

For an example on how to integrate the lovetoys with love2d, have a look at our [example](https://github.com/lovetoys/lovetoys-examples) repository.

### Configuration
After requiring, configure lovetoys by passing a configuration table to the `initialize` function.
For example, if you want debug output, pass the option `debug = true`:

```lua
lovetoys.initialize({
    debug = true
})
```

The following table lists all available options:

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| debug | boolean | false | Makes lovetoys print warnings and notifications to stdout. |
| globals | boolean | false | If true, lovetoys will make all its classes available via the global namespace. (e.g. Entity instead of lovetoys.Entity) |
| middleclassPath | string | nil | Path to user's copy of middleclass |

> :warning: Once you've called `initialize`, the configuration will be the same every time you `require('lovetoys')`.

## Quickstart
```lua
-- Include the library.
local lovetoys = require('lovetoys')

-- Initialize:
-- debug = true will enable library console logs
-- globals = true will register lovetoys classes in the global namespace
-- so you can access i.e. Entity() in addition to lovetoys.Entity()
lovetoys.initialize({globals = true, debug = true})

function love.load()
    -- Define a Component class.
    local Position = Component.create("position", {"x", "y"}, {x = 0, y = 0})
    local Velocity = Component.create("velocity", {"vx", "vy"})

    -- Create and initialize a new Entity.
    -- Note we can access Entity() in the global
    -- namespace since we used globals = true in 
    -- the lovetoys initialization.
    local player = Entity()
    player:initialize()

    -- Add position and velocity components. We are passing custom default values.
    player:add(Position(150, 25))
    player:add(Velocity(100, 100))
    
    -- Create a System class as lovetoys.System subclass.
    local MoveSystem = class("MoveSystem", System)

    -- Define this System's requirements.
    function MoveSystem:requires()
        return {"position", "velocity"}
    end

    function MoveSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local position = entity:get("position")
            local velocity = entity:get("velocity")
            position.x = position.x + velocity.vx * dt
            position.y = position.y + velocity.vy * dt
        end
    end

    -- Create a draw System.
    local DrawSystem = class("DrawSystem", System)

    -- Define this System requirements.
    function DrawSystem:requires()
        return {"position"}
    end

    function DrawSystem:draw()
        for _, entity in pairs(self.targets) do
            love.graphics.rectangle("fill", entity:get("position").x, entity:get("position").y, 10, 10)
        end
    end

    -- Finally, we setup an Engine.
    engine = Engine()
    engine:addEntity(player)

    -- Let's add the MoveSystem to the Engine. Its update() 
    -- method will be invoked within any Engine:update() call.
    engine:addSystem(MoveSystem())
    
    -- This will be a 'draw' System, so the
    -- Engine will call its draw method.
    engine:addSystem(DrawSystem(), "draw")
end

function love.update(dt)
    -- Will run each system with type == 'update'
    engine:update(dt)
end

function love.draw()
    -- Will invoke the draw() method on each system with type == 'draw'
    engine:draw()
end
```

## API Reference

lovetoys primarily consists of a few classes that are implemented using [middleclass](https://github.com/kikito/middleclass). By default, they are available via the lovetoys object:

```lua
local lovetoys = require('lovetoys')
-- Example: using constructors
local entity = lovetoys.Entity()
local system = lovetoys.System()
local engine = lovetoys.Engine()
-- the middleclass `class` object
local class = lovetoys.class ()
```

### Entity
The Entity is the basic building block of your game. You can loosely think of it as an object in your game, such as a player or a wall. From the technical side, it basically represents a collection of components.

#### Entity(parent)
- **parent** (Entity) - Parent entity

This function returns a new instance of an entity. If you specify a parent entity, you can later access it via the `.parent` property. Also, the parent entity will get a reference to its newly created child, accessible by its `.children` table.

> :warning: If you add an entity without a parent to the engine, the engine will set the root entity as its parent.

#### Entity:setParent(parent)
- **parent** (Entity) - Parent entity

Use this method to set a new parent on an entity. It will take care of removing itself from the children of its previous parent and registering as a child of the new parent.

#### Entity:getParent()

Returns the entities parent.

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
Collection of functions for creating and working with Component classes. There is no `Component` class; As components are only 'data bags', you can just use standard middleclass classes to implement your components.

#### Creating a simple component

```lua
local Color = class('Color');

function Color:initialize(r, g, b)
    self.r = r
    self.g = g
    self.b = b
end
```

The `Component.create()` function can automatically generate simple component classes like these for you.

#### Component.register(path)
- **path** A path in a format accepted by require()

Register the component for loading it conveniently with Component.load. Registered components are stored in a local table which stays the same across different `require()`s.

#### Component.load(components)
- **components** A list containing component names

Load the specified components, sparing you lots of calls to `require()`.

```lua
local Color, Transform, Drawable = Component.load({"Color", "Transform", "Drawable"})
-- Create a component for the color black
Color(0, 0, 0)
```

#### Component.create(name, [fields, defaults])
- **fields** (Table) - A list of Strings specifying the property names of the new component. The constructor of the component class will accept each of these properties as arguments, in the order they appear in the `fields` list.
- **defaults** (Table) - Key value pairs where each pair describes the default value for the property named like the pairs key.

Create a new component class. This will also call `Component.register` for you.

```lua
-- Create a Color component with the default color set to blue
local Color = Component.create("Color",
    {"r", "g", "b"},
    {r = 0, g = 0, b = 255})
-- Create a component for the color violet
Color(255)
```

### System
Systems provide the functionality for your game. The engine manages all Systems and assigns all entities with the right components to them.

All your systems have to be derived from the `System` class. An example how to do this can be found below.

There are two types of Systems: "update" and "draw" Systems. Update systems perform logic operations, like moving a player and updating physics. Their `update` method is called by the engine.
Draw systems are responsible for rendering your game world on screen. Their `draw` method is also called by the engine.

#### An example for a custom system
To implement functionality in your game, you create custom Systems. You inherit from the `System` class and override some methods to specify your System's behavior.

To create your own system, you use the `class` function provided by MiddleClass. The first argument is the name of your new System, the second is the Class you want to inherit from. The specific methods you can override are specified below.

```lua
local CustomSystem = class("CustomSystem", System)

function CustomSystem:initialize(parameter)
    System.initialize(self)
    self.parameter = parameter
end

function CustomSystem:update(dt)
    for key, entity in pairs(self.targets) do
        local foo =  entity:get("Component1").foo
        entity:get("Component2").bar = foo
    end
end

function CustomSystem:requires()
    return {"Component1", "Component2"}
end

return CustomSystem
```

#### System:requires() return {"Componentname1", "Componentname2", ...} end
This function defines what kind of entities shall be managed by this System. The function has to be overridden in every System or it won't get any entities! The strings inside the returned table define the components a entity has to contain, to be managed by the System. Those entities are accessible in `self.targets`.

If you want to manage different groups of entities just return a table that looks like this:

`return {group1 = {"Componentname1", "Componentname2"}, group2 = {"Componentname3", "Componentname4"}}`

The different entities are now accessible under `system.targets.group1` and `system.targets.group2`.
An entity can be contained by the same system multiple times in different groups if it matches the varying component constellations.

#### System:update(dt)
- **dt** (Number) - The time passed since the last update, in seconds.

This function is going to be called by the engine every tick.

#### System:draw()
This method is going to be called by the engine every draw.

#### System:onAddEntity(entity, group)
- **entity** (Entity) - The entity added
- **group** (String) - The group the entity was added to

Overwrite this method in your system if you want to react when new entities are added to it. 
Override this method if you want to react to the addition of entities. This will get called once for each group the entity gets added to. If you return no groups from `System:requires()`, `group` will be `nil` and the callback will only get called once.

#### System:onRemoveEntity(entity, group)
- **entity** (Entity) - The entity that was removed
- **group** (String) - The group the entity was removed from

Override this method if you want to react to the removal of entities. This will get called once for each group the entity gets removed from. If you return no groups from `System:requires()`, `group` will be `nil` and the callback will only get called once.

### Engine
The engine is the most important part of the lovetoys and the most frequently used interface. It manages all entities, systems and their requirements, for you.

#### Engine()
Creates a new engine object. Every engine creates a rootEntity which becomes parent of all entities that don't have a parent yet.

#### Engine:getRootEntity()
Returns the root entity. Modify it to your needs!

#### Engine:addSystem(system, type)
- **system** (System) - Instance of the system to be added
- **type** (String) - optional; Should be either "draw" or "update"

This function registers the system in the engine. The systems' functions will be called in the order they've been added. As long as the system implements either the `update` or the `draw` function, lovetoys will guess the `type` parameter for you.

> :warning: If a system implements both `draw` and `update` functions, you will need to specify the `type` and add the system twice, once to draw and once to update. Otherwise lovetoys couldn't know in what order to execute the `update` and `draw` methods.

#### Engine:stopSystem(system)
- **system** (String) - the name of the system

If you want a system to stop, just call this function. It's draw/update function won't be called anymore until you start it again.

#### Engine:startSystem(system)
- **system** (String)
    the name of the system

Call this to start a stopped system.

#### Engine:toggleSystem(system)
- **system** (String)
    the name of the system

If the system is running, stop it. If it is stopped, start it.

#### Engine:addEntity(entity)
- **entity** (Entity) - Instance of the Entity to be added

Adds an entity to the engine and registers it with all systems that are interested in its component constellation.

#### Engine:removeEntity(entity, removeChildren, newParent)
- **entity** - (Entity) - Instance of the Entity to be removed
- **removeChildren** - (Boolean) Default is false
- **newParent** - (Entity) - Instance of another entity, which should become the new Parent

Removes the particular entity instance from the engine and all systems.
Depending on `removeChildren` all Children are going to deleted recursively as well.
If there is a new Parent defined, this entity becomes the new Parent of all children, otherwise they become children of `engine.rootEntity`.

#### Engine:getEntitiesWithComponent(component)
- **component** (String) - Class name of the component

Returns a list with all entities that contain this particular component.

#### Engine:getEntityCount(component)
- **component** (Number) - Returns the count of entities that contain this particular component.

#### Engine:update(dt)
- **dt** (Number) - Time since the last update, in seconds

Updates all logic systems.

#### Engine:draw()
Updates all draw systems.

#### Example for a löve2d main.lua file
For a more detailed and commented version with collisions and some other examples check the [main.lua file of the lovetoys example game](https://github.com/lovetoys/example/blob/master/main.lua).

```lua
-- Importing lovetoys
require("lib.lovetoys")

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
```

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

## Testing
You can find the tests in the `spec` folder. They are defined using the [busted](http://olivinelabs.com/busted) test framework.

To run the suite, install busted and simply execute `busted` in the lovetoys directory.

* * *

Copyright &copy; 2016 Arne Beer ([@Nukesor](https://github.com/Nukesor)) and Rafael Epplée ([@raffomania](https://github.com/raffomania))

This Software is published under the MIT License.

For further information check `LICENSE.md`.
