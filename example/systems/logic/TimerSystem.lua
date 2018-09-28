local TimerSystem = class("TimerSystem", System)

function TimerSystem:update(dt)
	for index, value in pairs(self.targets) do
		value:get("Timing").timer = value:get("Timing").timer+dt
	end
end


function TimerSystem:requires()
	return {"Timing", "Position"}
end

return TimerSystem
