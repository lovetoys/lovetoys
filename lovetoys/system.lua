function table.firstElement(list)
    for index, value in pairs(list) do
        return value
    end
end

System = class("System")

function System:__init()
    -- Liste aller Entities, die die RequiredComponents dieses Systems haben
    self.priority = math.huge
    self.targets = {}
end

function System:update(dt) end

function System:draw() end

function System:requires() return {} end

function System:addEntity(entity, category)
    if category then
        self.targets[category][entity.id] = entity
    else
        self.targets[entity.id] = entity
    end
end

function System:removeEntity(entity)
    if table.firstElement(self.targets) then
        if table.firstElement(self.targets).__name then
            self.targets[entity.id] = nil
        else
            local tableindex = 1
            for index, value in pairs(self:requires()) do
                if self.targets[index] then
                    self.targets[index][entity.id] = nil
                end
            end
        end
    end
end

