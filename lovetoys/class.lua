function class(name, super)
    -- main metadata
    local cls = {}

    -- copy the members of the supercls
    if super then
        for k,v in pairs(super) do
            cls[k] = v
        end
    end

    cls.__name = name
    cls.__super = super

    -- when the cls object is being called,
    -- create a new object containing the cls'
    -- members, calling its __init with the given
    -- params
    cls = setmetatable(cls, {__call = function(c, ...)
        local obj = {}
        for k,v in pairs(cls) do
                obj[k] = v
        end
        superInit(obj)
        if obj.__init then obj:__init(...) end
        return obj
    end})
    
    return cls
end

function superInit(object, super)
    if super then
        if getSuper(super) then
            superInit(object, getSuper(super))
        end
        if super.__init then
            super.__init(object)
        end
    elseif getSuper(object) then
        superInit(object, getSuper(object))
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

