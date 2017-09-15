local util = {}

function util.firstElement(list)
    local _, value = next(list)
    return value
end

function util.listLength(list)
    count = 0
    for _, item in pairs(list) do
        count = count + 1
    end
    return count
end


return util
