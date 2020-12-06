--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]
--[[
    ADDITIONAL IMPLEMENTATIONS
    Line: 45 - added a rule that emptiness can not be spawned in the first two tiles
]]
LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    --ADDED
    local unlock = false
    local unlocked = false
    local completed = false
    local lockAndKey = math.random(1, 4)
    
    --ADDED END

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        --ADDED a rule that emptiness can not be spawn in the frist two tiles
        if math.random(7) == 1 and x > 32 and  x < 160 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end
            --ADDED
            if math.random(15) == 1 then
                -- lock block
                local lockBrick = GameObject {
                    texture = 'keys-and-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = lockAndKey + 4, 
                    collidable = true,
                    consumable = true,
                    solid = false,

                    onConsume = function(player, object)
                        if unlock then 
                            if unlocked == false then
                                gSounds['unlock']:play()
                                unlocked = true
                                completed = true
                                unlock = false
                                local pols = {POL_YELLOW, POL_GREEN, POL_RED, POL_BLUE}
                                local Pol = pols[lockAndKey]
                                local flag = FLAGS[lockAndKey] 
                                table.insert(Pol, flag)
                                for i = 1, 3 do 
                                    local polFlag = GameObject {
                                        texture = 'flags',
                                        x = width * 15,
                                        y = (2 + i) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = Pol[i],
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        onConsume = function(player, object)
                                            if completed then
                                                gSounds['newlevel']:play()
                                                player.score = player.score + 2000
                                                score = player.score
                                                completed = false
                                                gStateMachine:change('play')
                                            end    
                                        end
                                    }
                                    table.insert(objects, polFlag)
                                end 
                                for i = 1, 3 do 
                                    table.insert(objects, GameObject {
                                        texture = 'tiles',
                                        x = width * 15,
                                        y = (5 + i) * TILE_SIZE,
                                        width = 16,
                                        height = 16,
                                        frame = TILE_ID_GROUND,
                                        collidable = true,
                                        consumable = false,
                                        solid = true})
                                    end
                            end    
                        else
                            gSounds['empty-block']:play()
                        end    
                    end           
                }
                table.insert(objects, lockBrick)  
            end
            --ADDED END  
            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(3) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                --ADDED    
                                else
                                    local key = GameObject {
                                        texture = 'keys-and-locks',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = lockAndKey,
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            unlock = true
                                        end
                                    }
                                
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [key] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, key)
                                --ADDED END    
                                end    
                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )    
            end
        end
    end
    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end

