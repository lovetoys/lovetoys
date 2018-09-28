local MultipleRequirementsSystem = class("MultipleRequirementsSystem", System)

function MultipleRequirementsSystem:update()

    for index, value in pairs(self.pool1) do
        stupid = 1+1
        stupid = 5
    end

    for index, value in pairs(self.pool2) do
        evenmorestupid = 12%5
        evenmorestupid = "herpderp"
    end

end

function MultipleRequirementsSystem:requires()

    return {pool1 = {"Position"}, pool2 = {"Timing"}, pool3 = {"Timing", "Position"}}
end

function MultipleRequirementsSystem:printStuff()
    print("pool1 : " .. table.count(self.targets["pool1"]))
    print("pool2 : " .. table.count(self.targets["pool2"]))
    print("pool3 : " .. table.count(self.targets["pool3"]))
end

function table.count(list)
    local counter = 0
    for index, value in pairs(list) do
        counter = counter + 1
    end
    return counter
end

return MultipleRequirementsSystem
