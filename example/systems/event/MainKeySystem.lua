local Timing, IsCircle, Position, Physic = Component.load({"Timing", "IsCircle", "Position", "Physic"})

local MainKeySystem = class("MainKeySystem", System)

function MainKeySystem:fireEvent(event)
    if event.key == "s" then
        for i = 1, 20, 1 do
            entity = Entity()
            local x, y = love.math.random(0, 1000), love.math.random(0, 600)
            entity:add(Position(x, y))

            local body = love.physics.newBody(_G.world, x, y, "dynamic")
            local shape = love.physics.newCircleShape(5)
            local fixture = love.physics.newFixture(body, shape, 1)
            fixture:setRestitution(0.9)
            fixture:setUserData(entity)
            body:setMass(2)

            entity:add(Physic(body, fixture, shape ))
            entity:add(IsCircle())

            engine:addEntity(entity)
        end
    elseif event.key == "a" then
        for i = 1, 20, 1 do
            entity = Entity()
            local x, y = love.math.random(0, 1000), love.math.random(0, 600)
            entity:add(Timing(love.math.random(0, 5000)))
            entity:add(Position(x, y))

            local body = love.physics.newBody(world, x, y, "dynamic")
            local shape = love.physics.newCircleShape(5)
            local fixture = love.physics.newFixture(body, shape, 0)
            fixture:setUserData(entity)
            fixture:setRestitution(1)
            body:setMass(2)

            entity:add(Physic(body, fixture, shape ))
            entity:add(IsCircle())

            engine:addEntity(entity)
        end
    elseif  event.key == "d" then
        for index, entity in pairs(engine:getEntitiesWithComponent("IsCircle")) do
            entity:get("Physic").body:destroy()
            engine:removeEntity(entity)
        end
    elseif event.key == "e" then
        engine:stopSystem("CircleDrawSystem")
    elseif event.key == "w" then
        engine:startSystem("CircleDrawSystem")
    end
end
return MainKeySystem
