BeginContact = class("BeginContact", Event)

function BeginContact:__init(a, b, coll)
    self.a = a
    self.b = b
    self.coll = coll
end