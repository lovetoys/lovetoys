require("lovetoys/engine")

require("systems/exampleDrawSystem")
require("systems/exampleSystem")

require("components/exampleComponent")
require("components/positionComponent")

require("events/keyPressed")
require("events/mousePressed")

function love.load()

    love.graphics.setMode(1000, 600, false, true, 0)

    -- A new instance of an engine is beeing created
    engine = Engine()
    -- A new instance of an eventmanager is beeing created
    eventmanager = EventManager()
    -- A new instance of a collisionmanager is beeing created
    collisionmanager = CollisionManager()

    -- The collisionmanager is beeing registered as a listener for the 
    -- "BeginContact" event.
    eventmanager:addListener("BeginContact", {collisionmanager, collisionmanager.fireEvent})

    -- Logic (update) systems are beeing added to the engine
    engine:addSystem(ExampleSystem(), "logic", 1)

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

function love:keypressed(key, u)
    eventmanager:fireEvent(KeyPressed(key, u))
end

function love:mousepressed(x, y, button)
    eventmanager:fireEvent(MousePressed(x, y, button))
end

function beginContact(a, b, coll)
    eventmanager:fireEvent(BeginContact(a, b, coll))
end