DrawableComponent = class("DrawableComponent")

function DrawableComponent:__init(image, r, sx, sy, ox, oy)
    self.image = image
    self.r = r
    if sx then self.sx = sx  end
    if sy then self.sy = sy  end
    if ox then self.ox = ox  end
    if oy then self.oy = oy  end
end
