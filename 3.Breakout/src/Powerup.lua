--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Slavko Mihajlovic
    slavkomihajl@protonmail.com
   
]]
Powerup = Class {}

function Powerup:init(skin, brick)
    self.width = 16
    self.height = 16
    self.dy = 50
    self.dx = 0
    self.skin = skin
    --set spawn location to the middle of the brick
    self.x = brick.x +((brick.width / 2) - (self.width / 2)) 
    self.y = brick.y +((brick.height / 2) - (self.height / 2))

    self.inPlay = true
end 
-- AA BB Colision
function Powerup:collides(target)
   
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    return true
end

function Powerup:update(dt)  
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],self.x, self.y)
    end    
end

