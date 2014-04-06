PolygonDrawSystem = class("PolygonDrawSystem", System)

function PolygonDrawSystem:draw()
    love.graphics.setColor(155, 155, 155)
    for index, entity in pairs(self.targets) do
        love.graphics.polygon("fill", entity:getComponent("DrawablePolygonComponent").body:getWorldPoints(
            entity:getComponent("DrawablePolygonComponent").shape:getPoints()))
    end
end

function PolygonDrawSystem:requires()
    return {"DrawablePolygonComponent"}
end
