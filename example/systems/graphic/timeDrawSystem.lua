TimeDrawSystem = class("TimeDrawSystem", System)

function TimeDrawSystem:draw() 
	love.graphics.setColor(255,255,255,255)
	for index, value in pairs(self.targets) do
		local position = value:get("PositionComponent")
        local time = math.floor(value:get("TimeComponent").timer)
		love.graphics.print(time , position.x, position.y)
	end
end

function TimeDrawSystem:requires()
	return {"TimeComponent", "PositionComponent"}
end

