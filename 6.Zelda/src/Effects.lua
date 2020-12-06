--[[
    GD50
    Legend of Zelda

    Author: Slavko Mihajlovic
    slavkomihajl@protonmail.com
]]

Effects = Class {}

function Effects:init(def, x, y) 

self.type = def.type
self.texture = def.texture
self.solid = def.solid
self.width = def.width
self.height = def.height
self.animation = Animation {
    texture = def.texture,
    frames = def.frames,
    interval = def.interval 
}
-- dimensions
self.x = x
self.y = y

-- default empty collision callback
self.onCollide = function() end
end

function Effects:update(dt)
    if self.animation then
        self.animation:update(dt)
    end

end

function Effects:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
               self.y + self.height < target.y or self.y > target.y + target.height)
end

function Effects:render()
    love.graphics.draw(gTextures[self.animation.texture], gFrames[self.animation.texture][self.animation:getCurrentFrame()],
        self.x, self.y)
end


