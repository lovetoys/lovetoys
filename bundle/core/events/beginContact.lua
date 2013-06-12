BeginContact = class("BeginContact", Event)

function BeginContact:__init(a, b, coll)
    self.__super.__init(self, self.__name)
    self.a = a
    self.b = b
    self.coll = coll
end