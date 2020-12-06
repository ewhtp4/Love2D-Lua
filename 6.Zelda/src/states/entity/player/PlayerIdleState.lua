--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    EntityIdleState.update(self, dt)
end

function PlayerIdleState:update(dt)
   
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    --ADDED
    if self.entity.direction == 'left' then
        if self.entity.potPicked then 
            self.entity:changeAnimation('idle-left-pot')
        else    
            self.entity:changeAnimation('idle-left')
        end    
    elseif self.entity.direction == 'right' then
        if self.entity.potPicked then
            self.entity:changeAnimation('idle-right-pot')
        else    
            self.entity:changeAnimation('idle-right')
        end    
    elseif self.entity.direction == 'up' then
        if self.entity.potPicked then
            self.entity:changeAnimation('idle-up-pot')
        else     
            self.entity:changeAnimation('idle-up')
        end    
    elseif self.entity.direction == 'down' then
        if self.entity.potPicked then 
            self.entity:changeAnimation('idle-down-pot')
        else     
            self.entity:changeAnimation('idle-down')
        end
    end 
    --ADDED END  
    if love.keyboard.wasPressed('space') then
        if not self.entity.potPicked then 
            self.entity:changeState('swing-sword')
        end    
    end
end