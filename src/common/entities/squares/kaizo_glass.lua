-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common/kaizo_image")
require("common/kaizo_collision")
require("common.kaizo_globals")

KaizoGlass = setmetatable({}, {__index = KaizoSquare})

KaizoGlass.name = "KaizoGlass"
KaizoGlass.__index = KaizoGlass

function KaizoGlass:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoGlass)

    o.col.up = 6
    o.col.down = 6
    o.col.left = 6
    o.col.right = 6


    o.image_id = 13 -- Default image ID for the square
    o.image = nil

    o.death_sound = GameContext.CurrentLevel:get_sound(8)

    if not o.death_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(8)
        GameContext.CurrentLevel:add_sound(sound)
        o.death_sound = sound
    end

    return o
end

function KaizoGlass:update()

    if self.die then
        self:destroy()
        if self.death_sound then
            self.death_sound:Stop()
            self.death_sound:Play()
        end
        return
    end
    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    
end

function KaizoGlass:HandleEntityCollision(ent, collide)
    local tempcollide = {up = 0, down = 0, left = 0, right = 0}

    if collide.up == 6 then
        tempcollide.up = 1
    end

    if collide.down == 6 then
        tempcollide.down = 1
    end

    if collide.left == 6 then
        tempcollide.left = 1
    end

    if collide.right == 6 then
        tempcollide.right = 1
    end

    if ent.is_player and collide.up == 6 then
        self.die = true
    end

    return tempcollide
end