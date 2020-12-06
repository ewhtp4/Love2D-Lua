--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Slavko Mihajlovic
    slavkomihajl@protonmail.com
    Original by : Colton Ogden
    cogden@cs50.harvard.edu

    The state in which we are waiting to serve the ball; here, we are
    basically just moving the paddle left and right with the ball until we
    press Enter, though everything in the actual game now should render in
    preparation for the serve, including our current health and score, as
    well as the level we're on.
]]
PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = 5000
    --ADDED PARAMS
    self.balls = { params.ball }
    self.powerups = {}
    self.key = params.key --attention
    -- give ball random starting velocity
    params.ball.dx = math.random(-200, 200)
    params.ball.dy = math.random(-60, -80)
    table.insert(self.balls, params.ball)
   
end
--UPDATE
function PlayState:update(dt)

    --KEY INPUT LOGIC
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    -- update positions based on velocity
    self.paddle:update(dt)
    
    --BALL UPDATE LOGIC
    for k, ball in pairs(self.balls) do 
        ball:update(dt)
        if ball:collides(self.paddle) then 
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy
            -- tweak angle of bounce based on where it hits the paddle
            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end
            gSounds['paddle-hit']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, k)
        end
    end  
    if #self.balls < 1 then -- changed to acomidate multiple balls 
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            --Paddle shrink function
            self.paddle:shrink()
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                key = self.key, 
                locked = self.locked
            })
        end
    end
    
    --BRICK COLLISON LOGIC
    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        for ballk, ball in pairs(self.balls) do
        -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then 
                -- trigger the brick's hit function, which removes it from play
                brick:hit(self.paddle, self.key)
                -- add to score
                --check if brick is not locked and if it's destroied
                if not brick.isLocked or not brick.inPlay then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25 +(brick.isLocked and 1 or 0) * 500)
                end
                if brick.isLocked and brick.inPlay then
                    powerup = Powerup(10, brick, self.paddle)
                end
                --Power up check
                if not brick.inPlay then
                    local powerup = nil --inisiate powerup to nothing
                    --Runs the probability function gotPowerup
                    if self:gotPowerup(brick) then 
                        powerup = Powerup(math.random(9,10), brick, self.paddle) -- if success gives a brick multiball poweup
                    end 
                    if powerup ~= nil then
                        powerup.x = brick.x + brick.width / 2 - powerup.width / 2
                        powerup.y = brick.y + brick.height 
                        table.insert(self.powerups, powerup) 
                    end    
                    -- if brick is locked and no key
                    if brick.isLocked then
                        self.key = false
                    end
                end
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)
                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)
                    -- play recover sound effect
                    gSounds['recover']:play()
                    --Paddle grow function
                    self.paddle:grow()
                end
                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[1],
                        recoverPoints = self.recoverPoints
                    })
                end
                -- collision code for bricks
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end
                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end
                -- only allow colliding with one brick, for corners
                break
            end 
        end
        brick:update(dt) 
    end

    --POWER UP UPDATE LOGIC

--Added powerup collision
    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
        if powerup:collides(self.paddle) then
            --some sound to put
            --checks if the powerup is a key
            if powerup.skin == 10 then
                self.key = true
            --Added (Multiball)    
            else
                self:multiBall()
            end
            powerup.inPlay = false
        end
        if not powerup.inPlay or powerup.y >= VIRTUAL_HEIGHT then
            table.remove(self.powerups, k)
        end
    end 
    if self.key then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][10],VIRTUAL_WIDTH - 120, 2)
    end    
end

--RENDER
function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end
    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    renderScore(self.score)

    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
    
    for k, ball in pairs(self.balls) do
        ball:render()
    end
    
    for k, powerup in pairs(self.powerups) do 
        powerup:render()
    end  
    if self.key then
        keyCollected()
    end 
end

--CHECK VICTORY FUNCTION
function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
--RANDOM POER UP GENERATE FUNCTION
function PlayState:gotPowerup(brick)
    return math.random(1, 2) <= 2 
end   
--MULTIBALL FUNCTION
function PlayState:multiBall()
    for i = 0, math.random(3, 8) do
        local newBall = Ball()
        newBall.skin = math.random(7)
        newBall.x = self.paddle.x + self.paddle.width / 2 - newBall.width / 2
        newBall.y = self.paddle.y - newBall.height 
        newBall.dx = math.random(-200, 200)
        newBall.dy = math.random(-60, -80)
        table.insert(self.balls, newBall)
    end
end

