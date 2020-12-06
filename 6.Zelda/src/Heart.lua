Heart = Class{}


function Heart:init(entity)
 
    self.type = 'heart'

    self.texture = 'hearts'
    self.frame = 5

    self.player = player
    self.solid = false

    self.defaultState = 'dropped'
    
    self.states = {
        ['droped'] = {
            frame = 5
        },
        ['picked'] = {
            frame = 1
        }
    }
    self.consumed = false
    self.flashTimer = 0
    self.entity = entity
    self.x = entity.x
    self.y = entity.y
    self.width = 16
    self.height = 16
    self.hearts = hearts
    -- default empty consume callback
    self.onConsume = function() end
end

function Heart:update(dt)
    
end

function Heart:render(adjacentOffsetX, adjacentOffsetY)
   
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][5],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end