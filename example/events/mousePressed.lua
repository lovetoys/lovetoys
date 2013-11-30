MousePressed = class("MousePressed")

function MousePressed:__init(x, y, button)
    self.button = button
    self.y = y
    self.x = x
end