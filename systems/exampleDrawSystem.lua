ExampleDrawSystem = class("ExampleDrawSystem", System)

function ExampleDrawSystem:draw() 
	for index, value in pairs(self.targets) do
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(value:getComponent("ExampleComponent").timer, 200, 100)
		print(rofl)
	end
end

function ExampleDrawSystem:getRequiredComponents()
	return {"ExampleComponent"}
end