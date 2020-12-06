--[[
    GD50
    Legend of Zelda

    Author: Slavko Mihajlovic
    slavkomihajl@protonmail.com
]]

Projectile = Class{}



function Projectile:init(def, x, y)
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame 

    
    self.solid = true

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states
    
    -- dimensions
    self.x = x
    self.y = y
    self.dx = -400
    self.dy = -60
    self.width = def.width
    self.height = def.height
    self.picked = false
    self.weaponized = false
    
    self.onCollide = function(player)
        self.player = player
        self.picked = true
        self.weaponized = false
        self.player.potPicked = true
        if self.state == 'spawned' then
            self.state = 'pickedup'
            self.psystem:emit(64)
            gSounds['heart']:play()
        elseif self.state == 'broken' then
            self.state = 'pickedup'
            gSounds['heart']:play()
            self.weaponized = true
        end    
    end

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.5, 3)
    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    self.psystem:setLinearAcceleration(-15, 0, 15, -80)
    self.psystem:setAreaSpread('normal', 10, 10)
end

function Projectile:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Projectile:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
               self.y + self.height < target.y or self.y > target.y + target.height)
end

function Projectile:render()

    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x, self.y)
    if self.type == 'pot' then 
        self.psystem:setColors(217/255, 87/255, 99/255, 255)
        if self.weaponized then    
            love.graphics.draw(self.psystem, self.x + (TILE_SIZE / 2), self.y)
        elseif self.picked then 
            love.graphics.draw(self.psystem, self.x + (TILE_SIZE / 2), self.y)
        end 
    else
        self.psystem:setColors(100/255, 100/255, 100/255, 255)
        if self.weaponized then    
            love.graphics.draw(self.psystem, self.x + (TILE_SIZE / 2), self.y)
        end 
    end                    
end

function Projectile:fire(player, projectile, effects, effect, dt)
    self.projectile = projectile
    self.player = player
    self.effects = effects
    self.effect = effect
    self.projectile.weaponized = true
    local root = nil
    local plane = nil
    if self.player.direction == 'left' then
        root = self.projectile.x - (TILE_SIZE * 5)
        if root <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            root = MAP_RENDER_OFFSET_X + TILE_SIZE
        end
    elseif self.player.direction == 'right' then
        root = self.projectile.x + (TILE_SIZE * 5)
        if root + self.projectile.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            root = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.projectile.width
        end
    elseif self.player.direction == 'up' then
        root = self.projectile.y - (TILE_SIZE * 5)
        if root <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.projectile.height / 2 then 
            root = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.projectile.height / 2
        end
    elseif self.player.direction == 'down' then
        root = self.projectile.y + (TILE_SIZE * 5)
        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE
        if root + self.projectile.height >= bottomEdge then
            root = bottomEdge - self.projectile.height
        end
    end 

    --local effectTypes = {'fireball', 'iceball', 'poisonball'}
    --local effect = effectTypes[math.random(#effectTypes)]
    if self.player.direction == 'left' or self.player.direction == 'right' then
        Timer.tween(0.35, {
            [self.projectile] = {x = root}
        })
        :finish(function()
            for i = 1, 5 do 
                if self.effect ~= nil then 
                    table.insert(self.effects, Effects(
                        EFFECTS_DEFS[self.effect], projectile.x + math.random(-TILE_SIZE, TILE_SIZE), projectile.y + math.random(-TILE_SIZE, TILE_SIZE))) 
                end               
            end        
        end)
    else
        Timer.tween(0.35, {
            [self.projectile] = {y = root}
        })
        :finish(function()
            for i = 1, 5 do 
                if self.effect ~= nil then 
                    table.insert(self.effects, Effects(
                        EFFECTS_DEFS[self.effect], projectile.x + math.random(-TILE_SIZE, TILE_SIZE), projectile.y + math.random(-TILE_SIZE, TILE_SIZE))) 
                end      
            end        
        end)
    end

    self.projectile.picked = false
    self.projectile.state = 'broken'
    self.player.effect = nil
end

function Projectile:broken(projectile, projectiles)
    self.projectile = projectile
    self.projectiles = projectiles
    self.psystem:setColors(100/255, 100/255, 100/255, 255)
    Timer.after(1, function()
        table.remove(self.projectiles, self.projectile)
    end)
end    


       