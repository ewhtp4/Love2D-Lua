--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]
SCORE_DUMMY = love.graphics.newImage('dummybird.png')
SCORE_OOOO = love.graphics.newImage('firstmedalbird.png')
SCORE_BRONS = love.graphics.newImage('bronscoin.png')
SCORE_SILVER = love.graphics.newImage('silvercoin.png')
SCORE_GOLD = love.graphics.newImage('goldcoin.png')

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
    
    if self.score < 1 then
        love.graphics.draw(SCORE_DUMMY, VIRTUAL_WIDTH / 2 - 30, 105)
        love.graphics.printf('Need to learn how to jump befoure you fly dummy!', 0, 170, VIRTUAL_WIDTH, 'center')
    elseif self.score > 0 and self.score < 4 then
        love.graphics.draw(SCORE_OOOO, VIRTUAL_WIDTH / 2 - 30, 105)
        love.graphics.printf('Here is a consultation price so you dont get depressed!', 0, 170, VIRTUAL_WIDTH, 'center')
    elseif self.score > 4 and self.score < 7 then
        love.graphics.draw(SCORE_BRONS, VIRTUAL_WIDTH / 2 - 25, 120)
        love.graphics.printf('OK you earned a little something!', 0, 170, VIRTUAL_WIDTH, 'center')
    elseif self.score > 7 and self.score < 10 then
        love.graphics.draw(SCORE_SILVER, VIRTUAL_WIDTH / 2 - 25, 120)
        love.graphics.printf('Now your getting somewhere!', 0, 170, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.draw(SCORE_GOLD, VIRTUAL_WIDTH / 2 - 25, 120)
        love.graphics.printf('Well your ready to leave the nest!!!', 0, 170, VIRTUAL_WIDTH, 'center')
    end    
    love.graphics.printf('Press Enter to Play Again!', 0, 190, VIRTUAL_WIDTH, 'center')
end