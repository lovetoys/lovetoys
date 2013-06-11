require("core/class")
require("core/component")
require("core/engine")
require("core/entity")
require("core/event")
require("core/systems")

require("systems/event/collisionSelectSystem")

function love.load()
    engine = Engine()
    engine:addSystem()


end


function love.update(dt)
	engine:draw()
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