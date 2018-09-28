# Lovetoys-example

This is a small example game that shows how to use the lovetoys in practice.

## Component:
[position.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/components/physic/position.lua): Basic Structure of a component.

## Entity:
[main.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/main.lua) Line 98-105: How to create an entity, add Components to it and finally add the entity to the engine.  
[mainKeySystem.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/systems/event/mainKeySystem.lua) Line 46: How to remove an Entity from the engine.  

## System:
[circleDrawSystem.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/systems/graphic/circleDrawSystem.lua): Basic Structure of a system.  
[mainKeySystem.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/systems/event/mainKeySystem.lua) Line 49 following: Start and stop systems
[multipleRequirementsSystem](https://github.com/lovetoys/Lovetoys-examples/blob/master/systems/test/multipleRequirementsSystem.lua) How to write a System with multiple component requirements and how to access the different target lists.

## Engine:
[main.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/main.lua) Line 54: How to create an engine and add all the stuff to it.  
Line 112: Engine update function.  
Line 123: Engine draw function.  


## Eventmanagement:
[keyPressed.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/events/keyPressed.lua) Basic structure of an event.  
[mainKeySystem.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/systems/event/mainKeySystem.lua) This is a typical event system.  
[main.lua](https://github.com/lovetoys/Lovetoys-examples/blob/master/main.lua) Line 79: How to add a system to an existing eventmanager.  
Line 127: How to fire an event to the eventmanager.  
