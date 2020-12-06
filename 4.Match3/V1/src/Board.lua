--[[
    ADDITION IMPLEMENTATIONS:
    Lines: 17 - 19 Added variables for variety matches, level and shine
    will turn the first matchable tilein to a shiny tile)
    Lines: 23 - 25 Logic to reinitialize Tiles if no matches found (redundant)
    Lines: 80 - 100, 117 - 134, 154 -171, 187 - 204 Check for a match with a shiny tile
    Line: 238 Variable to set the tile variety depending on the level
    Lines: 299 - 301 - Logic to spawn a shiny tile with 20% chance
    Line: 304 Random tile spawn depending on the level
    Line: 316 Reset shine variable
    ADDED FUNCTIONS
    Lines: 337 - 344 Delete Row Function
    Lines: 348 - 358 Swap Tile Function
    Lines: 362 - 385 Check For Matches Function (plus Last Hope Implementations)
    Lines: 389 - 440 Calculating Matches whit Variety of Tiles  
]]
Board = Class{}
--ADDED a level param
function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    --ADDED 
    self.varMatches = {}
    self.level = level
    self.shine = false
    --ADDED END
    self:initializeTiles()
    --ADDED
    while not self:checkMatch() do
        self:initializeTiles()
    end
    --ADDED END    
end

function Board:initializeTiles()
    self.tiles = {}
    for tileY = 1, 8 do
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            -- create a new tile at X,Y with a random color and variety
            --ADDED
           table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(8), math.random(1,self.level),self.shine))
            --END ADDED    
        end
    end

    while self:calculateMatches() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end
--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}
    
    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}
                    --ADDED
                    local row = false

                    for x2 = x - 1, x - matchNum, -1 do 
                        if self.tiles[y][x2].shine then
                            row = true
                            self.tiles[y][x].shine = false
                            break
                        end
                    end

                    if row then
                        match = self:deleteRow(y)
                    else    
                    -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do  
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end 
                    --ADDED END   
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            --ADDED
            local row = false
            for x = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shine then
                    row = true
                    self.tiles[y][x].shine = false
                    break
                end    
            end
            if row then
                match = self:deleteRow(y)
            else    
                -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end
            --ADDED END    
            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}
                    --ADDED
                    local row = false

                    for y2 = y - 1, y - matchNum, -1 do
                        if self.tiles[y2][x].shine then
                            row = true
                            self.tiles[y][x].shine = false
                            break
                        end    
                    end
                    if row then
                        match = self:deleteRow(y - 1)
                    else    
                        for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    end
                    --ADDED END    
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            --ADDED
            local row = false
            for y = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shine then
                    row = true
                    self.tiles[y][x].shine = false
                    break
                end    
            end
            if row then
                match = self:deleteRow(y)
            else    
                -- go backwards from end of last row by matchNum
                for y = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end
            --ADDED END    
            table.insert(matches, match)
        end
    end
    -- store matches for later reference
    self.matches = matches
    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end
--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
--ADDED a level param
function Board:getFallingTiles(level)
    -- tween table, with tiles as keys and their x and y as the to values
    
    local tweens = {}
    self.level = level 
    --ADDED new variable called tile type   
    tile_type = math.random(1,self.level)
    --ADDED END  
    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                --ADDED a random 20% chance to get a shine tile
                if math.random(1,5) == 1 then
                    self.shine = true
                end
                --ADDED changed math.random(6) to tile_type
                local tile = Tile(x, y, math.random(8), tile_type, self.shine)
                --END ADDED
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
            --ADDED reset tile top normal
            self.shine = false
            --ADDED END
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
--[[
    ADDITIONAL FUNCTIONS
]]
--ADDED
function Board:deleteRow(y)
    local match = {}
    for x = 1, 8 do
        table.insert(match, self.tiles[y][x])
    end
    return match
    --Some sound
end
--ADDED END  
--ADDED
function Board:swap(tile1, tile2) 
    local tempX = tile1.gridX
    local tempY = tile1.gridY 

    tile1.gridX = tile2.gridX 
    tile1.gridY = tile2.gridY 
    tile2.gridX = tempX
    tile2.gridY = tempY
    self.tiles[tile1.gridY][tile1.gridX] = tile1
    self.tiles[tile2.gridY][tile2.gridX] = tile2
end  
--ADDED END       
--ADDED
function Board:checkMatch(lastHope)
    self.lastHope = lastHope
    for y = 1, 8 do
        for x = 1, 8 do
            local a = {(x > 1), (x < 8), (y > 1), (y < 8)}
            local b = {(x - 1), (x + 1), x, x}
            local c = {y, y, (y - 1), (y + 1)}
            for i = 1, 4 do
                if a[i] then
                    self:swap(self.tiles[y][x], self.tiles[c[i]][b[i]])
                    if self:calculateMatches() then
                        self:swap(self.tiles[y][x], self.tiles[c[i]][b[i]])
                            if lastHope then
                                self.tiles[c[i]][b[i]].shine = true
                            end    
                        return true
                    end
                    self:swap(self.tiles[y][x], self.tiles[c[i]][b[i]])
                end
            end
        end
    end
    return false
end  
--ADDED END
--ADDED a function to calculate ttype matches
function Board:calculateVarMatches()
    local varMatches = 0
    -- horizontal matches first
    for y = 1, 8 do
        local varietyToMatch = self.tiles[y][1].variety
        local colorToMatch = self.tiles[y][1].color
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then 
                if self.tiles[y][x].variety == varietyToMatch then
                    if self.tiles[y][x].variety ~= 1 then
                        varMatches  = varMatches + self.tiles[y][x].variety
                    end    
                end        
                -- don't need to check last two if they won't be in a match   
            else    
                if x >= 7 then
                    break
                end
            end
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local varietyToMatch = self.tiles[1][x].variety
        local colorToMatch = self.tiles[1][x].color

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then 
                if self.tiles[y][x].variety == varietyToMatch then
                    if self.tiles[y][x].variety ~= 1 then
                        varMatches  = varMatches + self.tiles[y][x].variety
                    end    
                end           
            else
                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end
    end    
    -- store matches for later reference
    self.varMatches = varMatches
    -- return matches table if > 0, else just return false
    return self.varMatches
end
--ADDED END
