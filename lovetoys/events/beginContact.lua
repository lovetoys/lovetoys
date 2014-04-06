BeginContact = class("BeginContact")

function BeginContact:__init(a, b, coll)
    -- First colliding body
    self.a = a
    -- Second colliding body
    self.b = b
    -- Collisionobject
    self.coll = coll
end

