--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]
--[[
    ADDITION IMPLEMENTATIONS:
    Line 20 Shine variable
    Lines: 52 - 55 Check for Shine and Render
]]
Tile = Class{}

function Tile:init(x, y, color, variety, shine)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32
    self.shine = shine
    -- tile appearance/points
    self.color = color
    self.variety = variety
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)
    
    
    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
    --ADDED    
    if self.shine == true then 
        love.graphics.setColor(255, 255, 255, 100/255)
        love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32, 4)
    end 
    --ADDED END     
end

