require("core/class")
require("core/component")
require("core/engine")
require("core/entity")
require("core/event")
require("core/system")

require("systems/event/collisionSelectSystem")

require("systems/exampleDrawSystem")
require("systems/exampleSystem")

require("components/exampleComponent")

require("core/events/beginContact")
require("core/events/keyPressed")
require("core/events/mousePressed")

function love.load()

    love.graphics.setMode(1000, 600, false, true, 0)

    engine = Engine()
    engine:addSystem(ExampleSystem(), "logic", 1)
    engine:addSystem(ExampleDrawSystem(), "draw")

    entity = Entity()
    entity:addComponent(ExampleComponent())
end


function love.update(dt)
	engine:update(dt)
end

function love.draw()
	engine:draw()
end 

function love:keypressed(key, u)
    engine:fireEvent(KeyPressed(key, u))
end

function love:mousepressed(x, y, button)
    engine:fireEvent(MousePressed(x, y, button))
end