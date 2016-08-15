<div align="center">
  <a href="https://github.com/lovetoys/lovetoys">
    <img width="150" src="http://cdn.rawgit.com/lovetoys/lovetoys/bc73d45634b1220746d1afd618fb1372e42fc096/logo_small.svg" />
  </a>
</div>
<h1 align="center">lövetoys</h1>

[![GitHub release](https://img.shields.io/github/release/lovetoys/lovetoys.svg?maxAge=2592000)](https://github.com/lovetoys/lovetoys/releases/latest)
[![Build Status](https://travis-ci.org/lovetoys/lovetoys.svg?branch=master)](https://travis-ci.org/lovetoys/lovetoys) [![Coverage Status](https://coveralls.io/repos/github/lovetoys/lovetoys/badge.svg?branch=master)](https://coveralls.io/github/lovetoys/lovetoys?branch=master)


lovetoys is an Entity Component System framework for game development with lua. Originally written for the LÖVE 2D game engine, it is actually compatible with pretty much any game that uses lua!
It is inspired by [Richard Lords Introduction](http://www.richardlord.net/blog/what-is-an-entity-framework) to ECS's. If you don't have any idea what this entity component stuff is all about, click that link and give it a read! It's totally worth it!

lovetoys is a full-featured game development framework, not only providing the core parts like Entity, Component and System classes but also containing a Publish-Subscribe messaging system as well as a Scene Graph, enabling you to build even complex games easily and in a structured way.

Though we have not reached version 1.0 yet, the software is tested, used in multiple games and definitely stable. If you find any bugs please create an issue and report them. Or just create a pull request :).

## Installation

The best way of installing lovetoys is by creating a submodule and cloning it right into your git repo.
Another way is to just download a [tarball](https://github.com/lovetoys/lovetoys/releases) and copy the files into your project folder.
The third way is to use Luarocks. Execute `luarocks install lovetoys`.

To use lovetoys with the default options, use the following:

```lua
local lovetoys = require('lovetoys.lovetoys')
lovetoys.initialize()
```

For an example on how to use the lovetoys have a look at our [example](https://github.com/lovetoys/lovetoys-examples) repository.

### Configuration
After requiring, configure lovetoys by passing a configuration table to the `initialize` function like so:

```lua
local lovetoys = require('lovetoys.lovetoys')
lovetoys.initialize({
    -- options here
})
```

For example, if you want debug output, pass the option `debug = true`:

```lua
local lovetoys = require('lovetoys.lovetoys')
lovetoys.initialize({
    debug = true
})
```

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| debug | boolean | false | Makes lovetoys print warnings and notifications to stdout. |
| globals | boolean | false | If true, lovetoys will make all its classes available via the global namespace. (e.g. Entity instead of lovetoys.Entity) |

Once you've called `initialize`, the configuration will be the same every time you `require('lovetoys.lovetoys')`.

## API Reference

lovetoys primarily consists of a few classes that are implemented using [middleclass](https://github.com/kikito/middleclass). By default, they are available via the lovetoys object:

```lua
local lovetoys = require('lovetoys')
-- Create a new instances
local entity = lovetoys.Entity()
local system = lovetoys.System()
local engine = lovetoys.Engine()
local component = lovetoys.Component()
local eventManager = lovetoys.EventManager()
-- Middleclass version we are using
local class = lovetoys.class ()
```

### Entity

The Entity is the basic object that is being administrated by the engine. It basicly represents a collection of components.

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

Collection of functions for creating and working with Component classes.

#### Component.load(components)

Load the specified components.

- **components** A list containing component names

```lua
local Color, Transform, Drawable = Component.load({"Color", "Transform", "Drawable"})
-- Create a component for the color black
Color(0, 0, 0)
```

#### Component.register(path)

Register the component for loading it conveniently with Component.load.

- **path** A path in a format accepted by require()

#### Component.create(name, [fields, defaults])

Create a new component class.

- **fields** (Table) - A list of Strings specifying the property names of the new component. The constructor of the component class will accept each of these properties as arguments, in the order they appear in the `fields` list.

- **defaults** (Table) - Key value pairs where each pair describes the default value for the property named like the pairs key.

```lua
-- Create a Color component with the default color set to blue
local Color = Component.create("Color",
    {"r", "g", "b"},
    {r = 0, g = 0, b = 255})
-- Create a component for the color violet
Color(255)
```

### System

Systems function as service provider inside of the ECS. The engine manages all Systems and assigns all suitable entities to the respective systems.

All custom systems have to be derived from the `System` class. An example how to do this can be found below.

There are two types of Systems: "logic" and "draw" Systems. Logic systems perform logic operations, like moving a player and updating physics. Their `update` method is called by `Engine:update()`, which in turn should be called in the `update` function of your game loop.
Draw systems are responsible for rendering your game world on screen. Their `draw` method is called by `Engine:draw()`, which is usually called in the `draw()` function of the game loop.

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

This function defines what kind of entities shall be managed by this System. The function has to be overwritten in every System or it won't get any entities! The strings inside the returned table define the components a entity has to contain, to be managed by the System. Those entities are accessible in `self.targets`.

If you want to manage different kinds of entities just return a table that looks like this:

`return {name1 = {"Componentname1", "Componentname2"}, name2 = {"Componentname3", "Componentname4"}}`

The different entities are now accessible under `system.targets.name1` and `system.targets.name2`.
An entity can be contained by the same system multiple times in different target pools if it matches the varying component constellations.

#### System:update(dt)

- **dt** (Number) - The time passed since the last update, in seconds.

This function is going to be called by the engine every tick.


#### System:draw()

This method is going to be called by the engine every draw.

#### System:onAddEntity(entity)

- **entity** (Entity) - The entity added

Overwrite this method in your system subclass. It will get called every time an entity gets added to the system.

### Engine

The engine is the most important part of our framework and the most frequently used interface. It manages all entities, systems and their requirements, for you.

#### Engine()

Creates a new engine object. Every engine containes a rootEntity which becomes parent of all entities, as long as they don't have a particular parent specified.

#### Engine:getRootEntity()

Returns the rootEntity entity, to get its children or add/remove components.

#### Engine:addSystem(system, type)

- **system** (System) - Instance of the system to be added.
- **type** (String) - optional; Should be either "draw", "logic" or unspecified

This function registers the system in the engine. The systems' functions will be called in the order they've been added. As long as the system implements either the `update` or the `draw` function, lovetoys will guess the `type` parameter for you.
If a system implements both, draw and update function, you will need to specify the `type` and add the system twice, once to draw and once to update. Otherwise lovetoys couldn't know in what order to execute the `update` and `draw` methods.

#### Engine:stop(system)

- **system** (String) - the name of the system

If you want a system to stop, just call this function. It's draw/update function won't be called anymore until you start it again.

#### Engine:start(system)

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

#### Engine:update(dt)

- **dt** (Number) - Time since the last update, in seconds

Updates all logic systems.

#### Engine:draw()

Updates all draw systems.

#### Example for a löve2d main.lua file

For a more detailed and commented version with collisions and some other examples check the [main.lua file of the lovetoys example game](https://github.com/lovetoys/example/blob/master/main.lua).

```lua
-- Importing lovetoys
require("lib.lovetoys.lovetoys")

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

## CollisionManager

`CollisionManager` was a class that helped with integrating a physics engine with the lovetoys.
We removed it from the framework. It performed too poorly and we felt it only bloated the framework while not being needed in many cases.

* * *

Copyright &copy; 2016 Arne Beer ([@Nukesor](https://github.com/Nukesor)) and Rafael Epplée ([@raffomania](https://github.com/raffomania))

This Software is published under the MIT License.

For further information check `LICENSE.md`.
