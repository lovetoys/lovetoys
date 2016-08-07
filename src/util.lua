lovetoys = require('src.namespace')
if not lovetoys.util then lovetoys.util = {} end

lovetoys.util.firstElement = function (list)
    local _, value = next(list)
    return value
end

lovetoys.debug = function (message)
    if lovetoys.config.debug then
        print(message)
    end
end
