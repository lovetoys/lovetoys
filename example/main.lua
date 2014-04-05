require("lovetoys/engine")

require("systems/exampleDrawSystem")
require("systems/exampleSystem")
require("systems/testSystem")
require("systems/multipleRequirementsSystem")

require("components/exampleComponent")
require("components/physicsComponent")
require("components/positionComponent")
require("components/drawableComponent")

require("events/keyPressed")
require("events/mousePressed")

function love.load()

    -- Creation of a new world
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*80, true)
    -- Enabling the collision functions
    world:setCallbacks(beginContact, endContact)

    love.window.setMode(1000, 600, {fullscreen=false, vsync=true, resizable=false})

    -- A new instance of an engine is beeing created
    engine = Engine()
    -- A new instance of an eventmanager is beeing created
    eventmanager = EventManager()
    -- A new instance of a collisionmanager is beeing created
    collisionmanager = CollisionManager()
    -- New instance of testSystem. This is just for us. We need to test the newest features of the beatiful lovetoys ;3
    testsystem = TestSystem()

    -- The collisionmanager is beeing registered as a listener for the 
    -- "BeginContact" event.
    eventmanager:addListener("BeginContact", {collisionmanager, collisionmanager.fireEvent})
    eventmanager:addListener("KeyPressed", {testsystem, testsystem.fireEvent})

    -- Logic (update) systems are beeing added to the engine
    engine:addSystem(ExampleSystem(), "logic", 1)
    engine:addSystem(TestSystem(), "passive", 1000)

    -- Drawing systems are beeing added to the engine
    engine:addSystem(ExampleDrawSystem(), "draw")


    -- Creation and adding of some Entities
    for i = 1, 20, 1 do
        entity = Entity()
        entity:addComponent(ExampleComponent(math.random(0, 5000)))
        entity:addComponent(PositionComponent(math.random(100, 900), math.random(100, 600)))
        engine:addEntity(entity)
    end
end


function love.update(dt)
    -- Engine update function
    engine:update(dt)
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

function beginContact(a, b, coll)
    eventmanager:fireEvent(BeginContact(a, b, coll))
end


--Collision function
function beginContact(a, b, coll)
    -- Dynamic creation of a new instance of BeginContact and firing it to the Eventmanager
    stack:current().eventmanager:fireEvent(BeginContact(a, b, coll))
end
