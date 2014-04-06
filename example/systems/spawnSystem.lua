SpawnSystem = class("SpawnSystem", System)

function SpawnSystem:__init()
    -- I know this is dirty and no good practice, but i am really lazy right now
    self.stuff = {}
end

function SpawnSystem:fireEvent(event)
    if event.key == "s" then
        for i = 1, 20, 1 do
            entity = Entity()
            local x, y = love.math.random(0, 1000), love.math.random(0, 600)
            entity:addComponent(PositionComponent(x, y))

            local body = love.physics.newBody(world, x, y, "dynamic")
            local shape = love.physics.newCircleShape(5) 
            local fixture = love.physics.newFixture(body, shape, 1)  
            fixture:setRestitution(0.9)  
            fixture:setUserData(entity)
            body:setMass(2)
                
            entity:addComponent(PhysicsComponent(body, fixture, shape ))

            table.insert(self.stuff, entity)
            engine:addEntity(entity)
        end
    elseif event.key == "a" then
        for i = 1, 20, 1 do
            entity = Entity()
            local x, y = love.math.random(0, 1000), love.math.random(0, 600)
            entity:addComponent(TimeComponent(love.math.random(0, 5000)))
            entity:addComponent(PositionComponent(x, y))

            local body = love.physics.newBody(world, x, y, "dynamic")
            local shape = love.physics.newCircleShape(5) 
            local fixture = love.physics.newFixture(body, shape, 0)  
            fixture:setUserData(entity)
            fixture:setRestitution(1)  
            body:setMass(2)
                
            entity:addComponent(PhysicsComponent(body, fixture, shape ))

            table.insert(self.stuff, entity)
            engine:addEntity(entity)
        end
    elseif  event.key == "d" then
        for index, value in pairs(self.stuff) do
            engine:removeEntity(value)
        end
    end
end
