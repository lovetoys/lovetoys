TimerSystem = class("TimerSystem", System)


function TimerSystem:update(dt)
	for index, value in pairs(self.targets) do
		value:get("TimeComponent").timer = value:get("TimeComponent").timer+dt
	end
end


function TimerSystem:requires()
	return {"TimeComponent", "PositionComponent"}
end

