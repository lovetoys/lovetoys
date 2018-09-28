local CircleDrawSystem = class("CircleDrawSystem", System)

function CircleDrawSystem:draw()
    for i, v in pairs(self.targets) do
        local position = v:get("Position")
        love.graphics.setColor(255, 150, 0)
        love.graphics.circle("fill", position.x, position.y, 5, 100)
    end
end

function CircleDrawSystem:requires()
    return {"Position", "Physic", "IsCircle"}
end

return CircleDrawSystem
