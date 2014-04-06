TimerSystem = class("TimerSystem", System)


function TimerSystem:update(dt)
	for index, value in pairs(self.targets) do
		value:getComponent("TimeComponent").timer = value:getComponent("TimeComponent").timer+dt
	end
end


function TimerSystem:requires()
	return {"TimeComponent", "PositionComponent"}
end

