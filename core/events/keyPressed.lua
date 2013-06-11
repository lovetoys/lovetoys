KeyPressed = class("KeyPressed", Event)

function KeyPressed:__init(key, u)
    self.__super.__init(self, self.__name)
    self.key = key
    self.u = u
end