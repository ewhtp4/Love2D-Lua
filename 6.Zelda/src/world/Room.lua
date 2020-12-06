--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()

    -- entities in the room
    self.entities = {}
    self:generateEntities()
    --ADDED
    self.effects = {}
    self.hearts = {}
    self.projectiles = {}
    self:generateProjectile()
    self:generatePikes()
    --ADDED END
  
    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    -- reference to player for collisions, etc.
    self.player = player

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
    
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 10 do
        local type = types[math.random(#types)]

        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            
            width = 16,
            height = 16,

            health = 1
            
        })

        if math.random(7) == 1 then 
            self.entities[i].heart = true
        end 

        if math.random(3) == 1 then 
            self.entities[i].powerup = true
        end 

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end
--[[
    --ADDED GENERATING PIKES OBJECTS
------------------------------------------------------------------------------------------------]]
function Room:generatePikes()
    for i = 1, 5 do 
        table.insert(self.effects, Effects(
            EFFECTS_DEFS['pikes'],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                        VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                        VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
        ))
    end    
end
--[[
    END OF ADDED FUNCTION
------------------------------------------------------------------------------------------------]]
--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))

    -- get a reference to the switch
    local switch = self.objects[1]

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end
end
--[[
    --ADDED GENERATING PROJECTILE OBJECTS
------------------------------------------------------------------------------------------------]]
function Room:generateProjectile()
    table.insert(self.projectiles, Projectile(
        PROJECTILE_DEFS['pot'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))

    local pot = self.projectiles[1]

    local types = {'box', 'barrel'}
    for i = 1, 7 do
        local type = types[math.random(#types)] 
        table.insert(self.projectiles, Projectile(
            PROJECTILE_DEFS[type],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                        VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                        VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
        ))
    end 
end
--[[
    END OF ADDED FUNCTION
------------------------------------------------------------------------------------------------]]

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end 
end
--[[
    --ADDED NEW UPDATE FUNCTION
------------------------------------------------------------------------------------------------]]
function Room:update(dt)
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    for k, effect in pairs(self.effects) do 
        effect:update(dt)
    end  

    self.player:update(dt)

    for i, entity in pairs(self.entities) do
        if  entity.health > 0 then
            entity:processAI({room = self}, dt)
            entity:update(dt)
            if self.player:collides(entity) and not self.player.invulnerable then
                if self.player.health == 0 then
                    gStateMachine:change('game-over')
                end 
                gSounds['hit-player']:play()
                self.player:damage(1)
                self.player:goInvulnerable(1.5)     
            end
        elseif entity.health <= 0 then 
            entity.dead = true
            if entity.heart then    
                local heartDrop = Heart(entity)
                table.insert(self.hearts, heartDrop)
                heartDrop.onConsume = function()
                    gSounds['heart']:play()
                    self.player:heal()
                    entity.heart = false
                end 
            end
            if entity.powerup then 
                local powerups = {'powerup_fire', 'powerup_ice', 'powerup_poison', 'powerup_CS50'}
                local powerup = powerups[math.random(1, 3)]
                table.insert(self.objects, GameObject(GAME_OBJECT_DEFS[powerup], entity.x, entity.y))
                entity.powerup = false
            end        
        end
        for i, projectile in pairs(self.projectiles) do 
            if projectile:collides(entity) then
                if not entity.dead then
                    if projectile.weaponized then
                        entity.health = entity.health - 1
                        gSounds['hit-enemy']:play()
                        entity.dead = true
                    end    
                end    
            end 
        end
        for i, effect in pairs(self.effects) do
            if effect.type ~= 'pikes' then 
                if entity:collides(effect) then 
                    entity.health = entity.health - 1
                    entity.dead = true 
                end    
            end
        end                     
    end
    
    for l, heart in pairs(self.hearts) do
        heart:update(dt)
        if self.player:collides(heart) then
            heart:onConsume() 
            table.remove(self.hearts, l)
        end
    end
    for k, object in pairs(self.objects) do
        object:update(dt)
        -- trigger collision callback on object
        if self.player:collides(object) then
            if object.type ~= 'switch' then 
                if object.type == 'powerup_fire' then
                    effectP = 'fireball'
                elseif object.type == 'powerup_ice' then
                    effectP = 'iceball'
                elseif object.type == 'powerup_poison' then
                    effectP = 'poisonball' 
                end    
                table.remove(self.objects, k)      
            end    
            object:onCollide()
        end
        for i, projectile in pairs(self.projectiles) do
            if projectile:collides(object) then
                if object.solid then
                    projectile.x = object.x 
                    projectile.y = object.Y
                end
            end 
        end           
    end
    for i, projectile in pairs(self.projectiles) do
        if projectile.picked then
            projectile.x = self.player.x
            projectile.y = self.player.y - TILE_SIZE 
            if love.keyboard.wasPressed('z') then
                projectile.picked = false
                self.player.potPicked = false
                if projectile.type == 'pot' then
                    effectP = 'flames'
                end    
                projectile:fire(self.player, projectile, self.effects, effectP, dt)
                projectile:update(dt)
                projectile:broken(i, self.projectiles)
            end      
        elseif self.player:collides(projectile) then
            if self.player.x + 2 < projectile.x then
                self.player.x = projectile.x - TILE_SIZE
            elseif self.player.x + 14 > projectile.x + TILE_SIZE then
                self.player.x = projectile.x + TILE_SIZE
            elseif self.player.y + 2 < projectile.y then
                self.player.y = projectile.y - TILE_SIZE  
            else 
                self.player.y = projectile.y + TILE_SIZE 
            end 
            if love.keyboard.wasPressed('z') then
                self.player.potPicked = true
                projectile:onCollide(self.player)
            end    
        end
        projectile.psystem:update(dt)
    end

    for i, effect in pairs(self.effects) do 
        if self.player:collides(effect) then 
            if self.player.health == 0 then
                gStateMachine:change('game-over')
            else 
                gSounds['hit-player']:play()
                self.player:goInvulnerable(1.5)
                self.player:damage(0.05)
            end     
        end
        if effect.type ~= 'pikes' then 
            Timer.after(5, function()
                self.flesh = true
                table.remove(self.effects, e)
            end)
        end
    end     
end
--[[
    END OF ADDED FUNCTION
------------------------------------------------------------------------------------------------]]
function Room:render()

    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY) 
    end
    for k, projectile in pairs(self.projectiles) do
        projectile:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end
    for k, effect in pairs(self.effects) do
        effect:render()
    end
    for k, entity in pairs(self.entities) do
        if entity.health > 0 then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    for k, heart in pairs(self.hearts) do
        heart:render(self.adjacentOffsetX, self.adjacentOffsetY) 
    end
    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - 6,
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()
end


