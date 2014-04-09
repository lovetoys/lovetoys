# Lovetoys

Lovetoys is a small bundle of helper classes and libraries consisting of 3 packages. The most important one is the Entity Component System which is based on [Richard Lords Introduction](http://www.richardlord.net/blog/what-is-an-entity-framework) to ECS's. If you don't have any idea what this entity component stuff is all about, click that link and give it a read! It's totally worth it!

Besides the Entity Component System the Lovetoys also contain an event manager for handling keypresses etc. and a collision manager for easier management of Löve2D collisions.

This Software is published under the MIT license. For further information check the LICENSE.md.

The Software is tested and should be stable. If you find any bugs please create an issue and report them.

## Installation

The best way of installing Lovetoys is creating a submodule and cloning it right into your git repo. 
Another way is to just download the files, especially the lovetoys folder, and copy them to your project folder.

The following text describes the different classes the lovetoys provide. To use everything just require lovetoys/engine.

For an example on how to use the lovetoys check our [example](https://github.com/Nukesor/lua-lovetoys/tree/master/example) folder.

## Entity Component System

### Entity

The Entity is the basic object that is beeing administrated by the engine. It functions merely as a container for components.

#### Entity:add(component)
component = Instance of a component.

Adds a component to this particular entity. 

#### Entity:remove(name)

name = Name of the component class  
typeof(name) = String  

Removes a component from this particular entity.  
    
#### Entity:get(Name)

name = Name of the component class
typeof(name) = String  

Returns the component or `nil` if the Entity has no component with the given `name`.

### Component

This doesn't do anything yet. It will be used for type checks someday.

### System

Systems function as service provider inside of the ECS. The engine manages all Systems and assigns all suitable entities to the respective systems.

There are two types of Systems: "logic" and "draw" Systems. Logic systems perform logic operations, like moving a player and updating physics. Their `update` method is called by `Engine:update()`, which in turn should be called in the `update` function of your game loop.
Draw systems are responsible for rendering your game world on screen. Their `draw` method is called by `Engine:draw()`, which is usually called in the `draw()` function of the game loop.


#### System:requires() return {"Componentname1", "Componentname2", ...} end 

This function defines what kind of entities shall be managed by this System. The function has to be overwritten in every System!  The strings inside the returned table define the components a entity has to contain, to be managed by the System. Those entities are accessible in `self.targets`.

If you want to manage different kinds of entities just return a table that looks like this:

`return {name1 = {"Componentname1", "Componentname2"}, name2 = {"Componentname3", "Componentname4"}}`

The different entities are now accessible under `system.targets[name1]` and `system.targets[name2]`.  
A entity can be contained by the same system multiple times in different target pools if they match the different component constellations.


#### System:update(dt) 

If the system type is "logic" , this function is called every time `Engine:update()` is called.

#### System:draw() 

If the system type is "draw", this function is called every time `Engine:draw()` is called.

#### A example for a custom created system

    CustomSystem = class("CustomSystem", System)

    function CustomSystem:update(dt)
        for key, entity in pairs(self.targets) do
            local foo =  entity:get("Component1").foo
            entity:get("Component2").bar = foo
        end
    end

    function CustumSystem:requires()
        return {"Component1", "Component2"}
    end

### Engine

The engine is the most important part of our framework and the most frequently used interface. It contains all systems, entities, requirements and entitylists and manages them for you.

#### Engine:addSystem(system, type)

system = Instance of the system to be added.  
type = "draw" or "logic" or nil  
typeof(type) = String  

Adds a system of the particular type to the engine. Depending on type either `system:draw()` or `system:update(dt)` is going to be called.  
If you just want a system to get certain entities don't pass type as a parameter. The system will get all entities that contain the required components, but no functions will be called on update or draw.

#### Engine:removeSystem(system)

system = Name of the system to be removed  
typeof(system) = String  

This function removes a system from all system lists. After this the system won't be managed or updated anymore.

#### Engine:addEntity(entity)

entity = Instance of Entity to be added

Adds an entity to the engine and sends it to all systems that are interested in its component constellation.

#### Engine:removeEntity(entity)

entity = Entity to be removed

Removes the particular entity from the engine and all systems.

#### Engine:getEntityList(component)

component = Class name of the component
typeof(component) = String  

Returns a list with all entities that contain this particular component.

#### Engine:update(dt)

Updates all logic systems.

#### Engine:draw()

Updates all draw systems.

## Eventmanager

This class is a simple eventmanager for sending events to their respective listeners.

#### EventManager:addListener(eventName, listener)

eventName = Name of the event-class to be added 
typeof(eventName) = String  

listener = {container, function}  
typeof(listener) = Table  
container = The table which contains the function  
function = The function that should be called  

Adds a function that is listening to the Event.  
An example for adding a Listener: `EventManager:addListener("EventName", {table, table.func})`.  
We need to do this so we can work with `self` as we are used to, as lua doesn't provide a native class implementation.

#### EventManager:removeListener(eventName, listener)

eventName = Name of the event-class  
typeof(eventName) = String  

listener = Name of the listener to be deleted  
typeof(listener) = String  

Removes a listener from this particular Event.

#### EventManager:fireEvent(event)

event = Instance of the event  
This function pipes the event through to every listener that is registered to the class-name of the event and triggers `listener:fireEvent(event)`.

## CollisionManager

This helperclass helps to avoid code redundancy and to create neater code.  
Our collisionmanager works in association with our eventmanager as it expects to get a event with the colliding entities.  
The required event is already contained and you can find an example of how to use it in our [example](https://github.com/Nukesor/lua-lovetoys/tree/master/example) folder.

#### CollisionManager:addCollisionAction(component1, component2, object)

component1, component2 = Names of the required components  
typeof(component1) = typeof(component2) = String  
object = Instance of the collision class.  

Adds a new collision to the manager. If two entities, who satisfy the requirements, collide, the `collision:action(entities)` function will be triggered.  
The entity that contains component1 will be given to you inside `entities.entity1` and the entity that contains component2 will be inside `entities.entity2`.  

If you want a entity to collide with any other entity, just name one of the required components "Everything".

## Class

A simple class file for OOP. 

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




Copyright &copy; 2013 Arne Beer and Rafael Epplee

Published under GNU General Public License Version 3  
For further information check the license.txt .
