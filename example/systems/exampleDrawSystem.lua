ExampleDrawSystem = class("ExampleDrawSystem", System)

function ExampleDrawSystem:draw() 
	love.graphics.setColor(255,255,255,255)
	for index, value in pairs(self.targets) do
		local position = value:getComponent("PositionComponent")
		love.graphics.print(value:getComponent("ExampleComponent").timer, position.x, position.y)
	end
end

function ExampleDrawSystem:getRequiredComponents()
	return {"ExampleComponent", "PositionComponent"}
end