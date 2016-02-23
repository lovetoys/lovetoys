System = class("System")

function System:initialize()
    -- Liste aller Entities, die die RequiredComponents dieses Systems haben
    self.targets = {}
    self.active = true
end

function System:requires() return {} end

function System:addEntity(entity, category)
    -- If there are multiple requirement lists, the added entities will
    -- be added to their respetive list.
    if category then
        if not self.targets[category] then
            self.targets[category] = {}
        end
        self.targets[category][entity.id] = entity
    else
        -- Otherwise they'll be added to the normal self.targets list
        self.targets[entity.id] = entity
    end

    if self.onAddEntity then self:onAddEntity(entity) end
end

function System:removeEntity(entity, component)
    if table.firstElement(self.targets) then
        if table.firstElement(self.targets).class then
            self.targets[entity.id] = nil
        else
            -- Removing entities from their respective category target list.
            for index, _ in pairs(self.targets) do
                if component then
                    for _, req in pairs(self:requires()[index]) do
                        if req == component then
                            self.targets[index][entity.id] = nil
                            break
                        end
                    end
                else
                    self.targets[index][entity.id] = nil
                end
            end
        end
    end
end

function System:pickRequiredComponents(entity)
    local components = {}
    local requirements = self:requires()

    if not requirements[1] then
    elseif type(requirements[1]) == "string" then
        for _, componentName in pairs(requirements) do
            table.insert(components, entity:get(componentName))
        end
    elseif type(requirements[1]) == "table" then
        if lovetoyDebug then
            print("Error: :pickRequiredComponents() is not supported for systems with multiple component constellations")
        end
    end
    return unpack(components)
end
