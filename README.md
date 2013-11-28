# Lovetoys

Lovetoys is a small bundle of helper classes and libraries consisting of 3 packages. The most important one is the Entity Component System which is based on [Richard Lords Introduction](http://www.richardlord.net/blog/what-is-an-entity-framework) to ECS's. If you don't have any idea what this entity component stuff is all about, click that link and give it a read! It's totally worth it!

Besides the Entity Component System the Lovetoys also contain an event manager for handling keypresses etc. and a collision manager for easier management of Löve2D collisions.

This Software is published under GPL General Public License Version 3.
For further information check the license.txt or read the online version under [GPL](http://www.gnu.org/licenses/gpl.txt)

## Installation

The best way of installing Lovetoys is creating a submodule and cloning it right into your git repo. 
Another way is to just download the files, especially the lovetoys folder, and copy them to your project folder.

The following text describes the different classes that the lovetoys provide. To use everything just require lovetoys/engine.

For an example on how to use the lovetoys check our `example` folder.

## Entity Component System
    
### Entity

The Entity is the basic object that is beeing administrated by the engine. It functions merely as a container for components.

#### Entity:addComponent(component)

component = Instance of a component.

Adds a component to this particular entity. 

#### Entity:removeComponent(name)

typeof(name) = String  
name = Name of the Component class  

Removes a component from this particular entity.  
    
#### Entity:getComponent(Name)

typeof(name) = String  
name = Name of the Component class

Returns the particular component. Returns `nil` if the Entity has no component with the name `name`.

### Component

This does not do anything yet. It will be used for type checks someday.

### System

Systems function as service provider inside of the ECS. The engine manages all Systems and assigns all compatible entities to the respective systems.

There are two types of Systems: "logic" and "draw" Systems. Logic systems perform logic operations, like moving a player and updating physics. Their `update` method is called by `Engine:update()`, which in turn should be called in the `update` function of your game loop.
Draw systems are responsible for rendering your game world on screen. Their `draw` method is called by `Engine:draw()`, which is usually called in the `draw()` function of the game loop.

#### System:getRequiredComponents() return {"Componentname1", "Componentname2", ...} end 

This function defines what kind of entities shall be managed by this System. The function has to be overwritten in every System!  The strings inside the returned table define the components a entity has to contain, to be managed by the System.

#### System:update(dt) 

If the system type is "logic" , this function is called every time `Engine:update()` is called.

#### System:draw() 

If the system type is "draw", this function is called every time `Engine:draw()` is called.

### Engine

The engine is the most important part of our framework and the most frequently used interface. It contains all systems, entities, requirements and entitylists and manages them for you.

#### Engine:addSystem(system, type)

system = Instance of the system.  
typeof(type) = String  
type = "draw" or "logic"

Adds a system of the particular type to the engine. Depending on type either `system:draw()` or `system:update(dt)` is going to be called.

#### Engine:addEntity(entity)

Adds an entity to the engine and sends it to all systems that are interested in its component constellation.

#### Engine:removeEntity(entity)

Removes the particular entity from the engine and all systems.

#### Engine:componentAdded(entity, added)

entity = The entity  
typeof(added) = List  
added = A list containing the class names of the added components

Checks if there is any system interested in the new component constellation and, if that is the case, adds the entity to the system.

#### Engine:componentRemoved(entity, removed)

entity = The entity  
typeof(added) = List  
added = A list which contains the class-names of the removed components

Removes the entity from all systems that required the listed components.

#### Engine:getEntityList(component)

typeof(component) = String  
component = Class name of the component

Returns a list with all entities that contain this particular component.

#### Engine:update(dt)

Updates all logic systems.

#### Engine:draw()

Updates all draw systems.

## Eventmanager

This class is a simple eventmanager for sending events to their respective listeners.

#### EventManager:addListener(eventName, listener)

typeof(listener) = Table  
listener = {container, function}  
container = The table which contains the function  
function = The function that should be called  
typeof(eventName) = String  
eventName = Name of the event-class  

Adds a function that is listening to the Event. 
An example for adding a Listener: `EventManager:addListener("EventName", {table, table.func})`.  
To work with `self` as we are used to, the first parameter of the listening function has to be `self`, e.g. `table.func(self, event)`.  

#### EventManager:removeListener(eventName, listener)

typeof(listener) = Table  
listener = {container, function}  
container = The table which contains the function  
function = The function that should be called  
typeof(eventName) = String  
eventName = Name of the event-class   

Removes a listener from this particular Event. `listener` has to be exactly the same as in `:addListener(eventName, listener)`.

#### EventManager:fireEvent(event)

event = Instance of the event  
This function pipes the event through to every listener that is registered to the class-name of the event and triggers `listener:fireEvent(event)`.

## CollisionManager

This helperclass helps to avoid code redundancy and to create neater code.  
Our collisionmanager works in association with our eventmanager as it expects to get a event with the colliding entities. This event is available in our example folder and is named "beginContact.lua". 

#### CollisionManager:addCollisionAction(component1, component2, object)

typeof(component1), typeof(component2) = String  
component = Name of the required components  
object = Instance of the collision class.  

Adds a new collision to the manager. If two entities, who satisfy the requirements, collide, the `collision:action(entities)` function will be triggered.   
The entity that contains component1 will be given to you inside `entities.entity1` and the entity that contains component2 will be inside `entities.entity2`. 


## Class

A simple class file for OOP. 

#### How to create a class

    Foo = class("Foo")

    -- The constructor of this class
    function Foo:__init(parameter)
        self.bar = parameter
    end

If you want to create a object of this class just call `Foo(parameter)` and it will return a object after calling the constructor.  

If you want to create a class that inherits from a superclass you have to do the following:  

    Foo = class("Foo", Superclass)

Now Foo calls the constructors of all superior classes on itself.


Copyright &copy; 2013 Arne Beer and Rafael Epplee

Published under GNU General Public License Version 3  
For further information check the license.txt .