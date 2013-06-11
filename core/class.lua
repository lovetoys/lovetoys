function class(name, super)
    -- main metadata
    local cls = {}

    -- copy the members of the superclass
    if super then
        for k,v in pairs(super) do
            class[k] = v
        end
    end

    class.__name = name
    class.__super = super

    -- when the class object is being called,
    -- create a new object containing the class'
    -- members, calling its __init with the given
    -- params
    class = setmetatable(class, {__call = function(c, ...)
        local object = {}
        for k,v in pairs(class) do
            --if not k == "__call" then
                object[k] = v
            --end
        end
        if object.__init then object:__init(...) end
        return object
    end})
        superInit(class)
    return class
end

function superInit(object, super)
    if super then
        if super.__init then
            superInit(object, getSuper(super))
            super.__init(object)
        end
    elseif getSuper(object) then
        superInit(object, getSuper(object))
        if getSuper(object).__init then
            getSuper(object).__init(object)
        end
    end
end

function getSuper(object)
    if object.__super then
        return object.__super
    end
end

function getName(object)
    return object.__name
end