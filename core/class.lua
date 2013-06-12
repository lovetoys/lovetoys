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
        local object = {}
        for k,v in pairs(cls) do
                object[k] = v
        end
        if object.__init then object:__init(...) end
        return object
    end})
    superInit(cls)
    return cls
end

function superInit(object, super)
    if super then
        if getSuper(super) then
            superInit(object, getSuper(super))
        end
        super.__init(object)
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