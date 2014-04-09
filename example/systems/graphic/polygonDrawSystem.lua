PolygonDrawSystem = class("PolygonDrawSystem", System)

function PolygonDrawSystem:draw()
    love.graphics.setColor(0, 255, 0, 50)
    for index, entity in pairs(self.targets) do
        love.graphics.polygon("fill", entity:get("DrawablePolygonComponent").body:getWorldPoints(
            entity:get("DrawablePolygonComponent").shape:getPoints()))
    end
end

function PolygonDrawSystem:requires()
    return {"DrawablePolygonComponent"}
end
