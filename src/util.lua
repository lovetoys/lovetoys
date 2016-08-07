local util = {}

function util.firstElement(list)
    local _, value = next(list)
    return value
end

return util
