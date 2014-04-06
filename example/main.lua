-- Importing lovetoys
require("lovetoys/engine")

-- Logic systems
require("systems/timerSystem")
require("systems/physicsPositionSyncSystem")

-- Graphic systems
require("systems/circleDrawSystem")
require("systems/polygonDrawSystem")
require("systems/timeDrawSystem")

-- Event systems
require("systems/mainKeySystem")

-- Testing and debugging systems
require("systems/testSystem")
require("systems/multipleRequirementsSystem")

-- Physic components
require("components/physicsComponent")
require("components/positionComponent")
require("components/drawablePolygonComponent")

-- Graphic components
require("components/drawableComponent")

-- Logic components
require("components/timeComponent")

-- Events
require("events/keyPressed")
require("events/mousePressed")

function love.load()

    -- Creation of a new world
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*80, true)
    -- Enabling the collision functions
    world:setCallbacks(beginContact, endContact)

    love.window.setMode(1000, 600, {fullscreen=false, vsync=true, resizable=false})

    -- A new instance of an Engine is beeing created.
    engine = Engine()
    -- A new instance of an EventManger is beeing created.
    eventmanager = EventManager()
    -- A new instance of a CollisionManager is beeing created.
    collisionmanager = CollisionManager()
    -- New instance of TestSystem. This is just for us. We need to test the newest features of the beautiful lovetoys ;3
    -- If you want to see an implementation of multiple required component constellations check the MultipleRequirementsSystem
    testsystem = TestSystem()

    -- New instance of MainKeySystem for adding and deleting physic bodies.
    mainkeysystem = MainKeySystem()

    -- The collisionmanager is beeing registered as a listener for the "BeginContact" event.
    eventmanager:addListener("BeginContact", {collisionmanager, collisionmanager.fireEvent})
    eventmanager:addListener("KeyPressed", {mainkeysystem, mainkeysystem .fireEvent})
    eventmanager:addListener("KeyPressed", {testsystem, testsystem.fireEvent})

    -- Logic (update) systems are beeing added to the engine
    engine:addSystem(TimerSystem(), "logic", 1)
    engine:addSystem(PhysicsPositionSyncSystem(), "logic", 2)

    -- Drawing systems are beeing added to the engine
    engine:addSystem(PolygonDrawSystem(), "draw", 1)
    engine:addSystem(CircleDrawSystem(), "draw", 2)
    engine:addSystem(TimeDrawSystem(), "draw", 5)

    -- Passive System beeing added. This systems draw or update function won't be called
    engine:addSystem(TestSystem(), "passive", 1000)

    -- Creation and adding of some Entities
    for i = 1, 20, 1 do
        entity = Entity()
        local x, y = love.math.random(100, 900), love.math.random(150, 600)
        entity:addComponent(DrawablePolygonComponent(world, x, y, 100, 10, "static", wall))
        entity:addComponent(TimeComponent(love.math.random(0, 5000)))
        entity:addComponent(PositionComponent(x, y))
        entity:getComponent("DrawablePolygonComponent").fixture:setUserData(entity)
        engine:addEntity(entity)
    end
end


function love.update(dt)
    -- Engine update function
    engine:update(dt)
    world:update(dt)
end

function love.draw()
    -- Engine draw function
    love.graphics.print("Press 'a' for spawning timer circles", 10, 10)
    love.graphics.print("Press 's' for spawning circles", 10, 30)
    love.graphics.print("Press 'd' for deleting all spawned circles", 10, 50)
    love.graphics.print("Press 'e' for removing the CircleDrawSystem", 10, 70)
    love.graphics.print("Press 'w' for adding the CircleDrawSystem again", 10, 90)
    engine:draw()
end 

function love.keypressed(key, isrepeat)
    eventmanager:fireEvent(KeyPressed(key, isrepeat))
end

function love.mousepressed(x, y, button)
    eventmanager:fireEvent(MousePressed(x, y, button))
end

--Collision function
function beginContact(a, b, coll)
    -- Dynamic creation of a new instance of BeginContact and firing it to the Eventmanager
    eventmanager:fireEvent(BeginContact(a, b, coll))
end

