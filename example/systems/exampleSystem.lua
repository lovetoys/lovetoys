ExampleSystem = class("ExampleSystem", System)


function ExampleSystem:update(dt)
	for index, value in pairs(self.targets) do
		value:getComponent("ExampleComponent").timer = value:getComponent("ExampleComponent").timer+dt
	end
end


function ExampleSystem:requires()
	return {"ExampleComponent", "PositionComponent"}
end