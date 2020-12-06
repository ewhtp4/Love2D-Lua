--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['powerup_fire'] = {
        type = 'powerup_fire',
        texture = 'powerup',
        frame = 1,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'dropped',
        states = {
            ['dropped'] = {
                frame = 1
            },
            ['picked'] = {
                frame = 1
            }
        }
    },
    ['powerup_ice'] = {
        type = 'powerup_ice',
        texture = 'powerup',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'dropped',
        states = {
            ['dropped'] = {
                frame = 2
            },
            ['picked'] = {
                frame = 2
            }
        }
    },
    ['powerup_poison'] = {
        type = 'powerup_poison',
        texture = 'powerup',
        frame = 3,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'dropped',
        states = {
            ['dropped'] = {
                frame = 3
            },
            ['picked'] = {
                frame = 3
            }
        }
    },
    ['powerup_CS50'] = {
        type = 'powerup_CS50',
        texture = 'powerup',
        frame = 4,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'dropped',
        states = {
            ['dropped'] = {
                frame = 4
            },
            ['picked'] = {
                frame = 4
            }
        }
    },
    
}