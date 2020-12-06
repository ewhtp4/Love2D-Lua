--
-- libraries
--

Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

require 'src/Animation'
require 'src/constants'
require 'src/Entity'
require 'src/entity_defs'
require 'src/GameObject'
require 'src/game_objects'
require 'src/Hitbox'
require 'src/Player'
require 'src/StateMachine'
require 'src/Util'
--ADDED
require 'src/Heart'
require 'src/Projectile'
require 'src/projectile_defs'
require 'src/Effects'
require 'src/effects_defs'
--ADDED END
require 'src/world/Doorway'
require 'src/world/Dungeon'
require 'src/world/Room'

require 'src/states/BaseState'

require 'src/states/entity/EntityIdleState'
require 'src/states/entity/EntityWalkState'

require 'src/states/entity/player/PlayerIdleState'
require 'src/states/entity/player/PlayerSwingSwordState'
require 'src/states/entity/player/PlayerWalkState'

require 'src/states/game/GameOverState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'

gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/tilesheet.png'),
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['character-walk'] = love.graphics.newImage('graphics/character_walk.png'),
    ['character-walk-pot'] = love.graphics.newImage('graphics/character_pot_walk.png'),
    ['character-swing-sword'] = love.graphics.newImage('graphics/character_swing_sword.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['pots'] = love.graphics.newImage('graphics/tilesheet.png'),
    ['boxes'] = love.graphics.newImage('graphics/tilesheet.png'),
    ['barrels'] = love.graphics.newImage('graphics/tilesheet.png'),
    ['switches'] = love.graphics.newImage('graphics/switches.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png'),
    ['flames'] = love.graphics.newImage('graphics/flames.png'),
    ['fireball'] = love.graphics.newImage('graphics/fireball_14x45.png'),
    ['iceball'] = love.graphics.newImage('graphics/iceball_14x41.png'),
    ['poisonball'] = love.graphics.newImage('graphics/poisonball_13x40.png'),
    ['powerup'] = love.graphics.newImage('graphics/powerup.png'),
    ['pikes'] = love.graphics.newImage('graphics/pikes.png'),
    ['entities'] = love.graphics.newImage('graphics/entities.png')
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], 16, 16),
    ['character-walk'] = GenerateQuads(gTextures['character-walk'], 16, 32),
    ['character-walk-pot'] = GenerateQuads(gTextures['character-walk-pot'], 16, 32),
    ['character-swing-sword'] = GenerateQuads(gTextures['character-swing-sword'], 32, 32),
    ['entities'] = GenerateQuads(gTextures['entities'], 16, 16),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 16, 16),
    ['pots'] = GenerateQuads(gTextures['pots'], 16, 16),
    ['boxes'] = GenerateQuads(gTextures['boxes'], 16, 16),
    ['barrels'] = GenerateQuads(gTextures['barrels'], 16, 16),
    ['powerup'] = GenerateQuads(gTextures['powerup'], 16, 16),
    ['flames'] = GenerateQuads(gTextures['flames'], 16, 32),
    ['fireball'] = GenerateQuads(gTextures['fireball'], 14, 45),
    ['iceball'] = GenerateQuads(gTextures['iceball'], 14, 41),
    ['poisonball'] = GenerateQuads(gTextures['poisonball'], 13, 40),
    ['pikes'] = GenerateQuads(gTextures['pikes'], 16, 16),
    ['switches'] = GenerateQuads(gTextures['switches'], 16, 18)
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['gothic-medium'] = love.graphics.newFont('fonts/GothicPixels.ttf', 16),
    ['gothic-large'] = love.graphics.newFont('fonts/GothicPixels.ttf', 32),
    ['zelda'] = love.graphics.newFont('fonts/zelda.otf', 64),
    ['zelda-small'] = love.graphics.newFont('fonts/zelda.otf', 32)
}

gSounds = {
    ['music'] = love.audio.newSource('sounds/music.mp3', 'static'),
    ['sword'] = love.audio.newSource('sounds/sword.wav', 'static'),
    ['hit-enemy'] = love.audio.newSource('sounds/hit_enemy.wav', 'static'),
    ['hit-player'] = love.audio.newSource('sounds/hit_player.wav', 'static'),
    ['door'] = love.audio.newSource('sounds/door.wav', 'static'),
    ['heart'] = love.audio.newSource('sounds/powerup-reveal.wav', 'static')
   
}