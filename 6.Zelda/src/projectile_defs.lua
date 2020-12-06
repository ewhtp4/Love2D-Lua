    PROJECTILE_DEFS = {
    ['pot'] = {
        type = 'pot',
        texture = 'pots',
        frame = 14,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'spawned',
        states = {
            ['spawned'] = {
                frame = 14
            },
            ['pickedup'] = {
                frame = 33
            },
            ['broken'] = {
                frame = 52
            },
        }
    },
    ['box'] = {
        type = 'box',
        texture = 'boxes',
        frame = 109,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'spawned',
        states = {
            ['spawned'] = {
                frame = 109
            },
            ['pickedup'] = {
                frame = 109
            },
            ['broken'] = {
                frame = 128
            },
        }
    },
    ['barrel'] = {
        type = 'barrel',
        texture = 'barrels',
        frame = 110,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        consumed = false,
        defaultState = 'spawned',
        states = {
            ['spawned'] = {
                frame = 110
            },
            ['pickedup'] = {
                frame = 110
            },
            ['broken'] = {
                frame = 111
            },
        }
    }
}