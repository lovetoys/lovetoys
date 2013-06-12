MousePressed = class("MousePressed", Event)

function MousePressed:__init(x, y, button)
    self.__super.__init(self, self.__name)
    self.button = button
    self.y = y
    self.x = x
end