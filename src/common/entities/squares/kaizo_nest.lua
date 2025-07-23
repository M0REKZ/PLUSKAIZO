-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common/kaizo_image")
require("common/kaizo_collision")
require("common.kaizo_globals")
require("common.entities.squares.kaizo_chicken")
require("common.entities.squares.kaizo_death_effect")

KaizoNest = setmetatable({}, {__index = KaizoSquare})

KaizoNest.name = "KaizoNest"
KaizoNest.__index = KaizoNest

function KaizoNest:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoNest)

    o.size.x = 64
    o.size.y = 32

    o.col.up = 4
    o.col.down = 4
    o.col.left = 4
    o.col.right = 4

    o.sec = nil

    o.image_id = 9 -- Default image ID for the square
    o.image = nil

    o.death_sound = GameContext.CurrentLevel:get_sound(1)

    if not o.death_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(1)
        GameContext.CurrentLevel:add_sound(sound)
        o.death_sound = sound
    end

    return o
end

function KaizoNest:update()

    if self.die then
        local effect = KaizoDeathEffect:new(self.pos.x,self.pos.y)
        effect.size = self.size
        effect.image_id = 9
        self.ref_layer:add_entity(effect)
        self.death_sound:Stop()
        self.death_sound:Play()
        self:destroy()
        return
    end
    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    
end

function KaizoNest:HandlePlayerCollision(player, collide)
    
    local player_layer
    player_layer = nil

    self.sec = GameContext.CurrentLevel:get_current_section()

    for _, layer in ipairs(self.sec.Layers) do
        for _, ent in ipairs(layer.Entities) do
            if ent == self then
                goto continue
            end

            if ent.marked_for_deletion then
                goto continue
            end

            if ent.is_player then
                player_layer = layer
                break
            end


            :: continue ::
        end
        if player_layer then
            break
        end
    end

    self.die = true

    if player_layer then
        local newchicken = KaizoChicken:new(Camera.x + WindowSize.x,Camera.y + 32)
        newchicken.active_out_of_camera = true --always active, since it spawns out of the camera
        player_layer:add_entity(newchicken)
    end
end