--[[
    PLUSKAIZO
    Copyright (c) Benjamín Gajardo All rights reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

require("common.kaizo_image")
require("common.kaizo_collision")
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

    o.death_sound = nil

    return o
end

function KaizoNest:update()

    if not self.death_sound then
        self.death_sound = KaizoContext.CurrentLevel:get_sound(1)
        if not self.death_sound then
            local sound = KaizoSound:new()
            sound:LoadByID(1)
            KaizoContext.CurrentLevel:add_sound(sound)
            self.death_sound = sound
        end
    end

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
    
    if self.die then
        return
    end

    local player_layer
    player_layer = nil

    self.sec = KaizoContext.CurrentLevel:get_current_section()

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