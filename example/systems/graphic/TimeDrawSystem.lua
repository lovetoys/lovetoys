local TimeDrawSystem = class("TimeDrawSystem", System)

function TimeDrawSystem:draw()
	love.graphics.setColor(255,255,255,255)
	for index, value in pairs(self.targets) do
		local position = value:get("Position")
        local time = math.floor(value:get("Timing").timer)
		love.graphics.print(time , position.x, position.y)
	end
end

function TimeDrawSystem:requires()
	return {"Timing", "Position"}
end

return TimeDrawSystem
