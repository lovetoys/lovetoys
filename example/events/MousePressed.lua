MousePressed = class("MousePressed")

function MousePressed:initialize(x, y, button)
    self.button = button
    self.y = y
    self.x = x
end