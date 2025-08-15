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

require("common.entities.kaizo_square")
require("common.kaizo_collision")
require("common.kaizo_globals")
require("common.kaizo_sound")

KaizoTomate = setmetatable({}, {__index = KaizoEGG})
KaizoTomate.name = "KaizoTomate"

KaizoTomate.__index = KaizoTomate

KaizoTomate.editor_properties = {}
KaizoTomate.editor_properties[1] = "is_edge_careful"
KaizoTomate.editor_properties[2] = "dir"

function KaizoTomate:new(x,y)
    local o = KaizoEGG:new(x,y)
    o = setmetatable(o,KaizoTomate)

    o.col.up = 4
    o.col.down = 2
    o.col.left = 2
    o.col.right = 2

    o.size.x = 22
    o.size.y = 25 - 7

    o.minusoffsety = 7

    o.image_id = 5 -- Default image ID for KaizoTomate
    o.image = nil
    o.can_collide_square = true
    o.has_collision_square = true
    o.is_player = false
    o.is_npc = true
    o.going_left = false
    o.going_right = false
    o.jumped = false
    o.die = false
    o.grounded = false
    o.can_die = true
    o.dir = -1
    o.frame = 0
    o.frametime = 0
    o.sec = 0
    o.is_edge_careful = false

    o.can_load_level_properties = true

    o.death_sound = nil

    return o
end

function KaizoTomate:update()
    if not self.death_sound then
        self.death_sound = KaizoContext.CurrentLevel:get_sound(5)
        if not self.death_sound then
            local sound = KaizoSound:new()
            sound:LoadByID(5)
            KaizoContext.CurrentLevel:add_sound(sound)
            self.death_sound = sound
        end
    end

    KaizoEGG.update(self)
end

function KaizoTomate:render()

    if not self.image then
        self.image = KaizoContext.CurrentLevel:get_entity_image(self.image_id)
        if not self.image then
            if not self.image then
                local image = KaizoImage:new()
                image:load_entity_image_by_id(self.image_id)
                KaizoContext.CurrentLevel:add_entity_image(image)
                self.image = image
            end
        end
    end

    if(self.image) then

        self.frametime = self.frametime + 1
		
		if(self.frametime > 4) then
		
			self.frame = self.frame + 1
			self.frametime = 0
        end
		
		if(self.frame > 7) then
			self.frame = 0
        end
		
		if(self.dir < 0) then
            self.image:render_incamera_scaled_from_to(0, (self.size.y + self.minusoffsety) * self.frame, self.size.x, self.size.y + self.minusoffsety, self.pos.x, self.pos.y - self.minusoffsety, self.size.x, self.size.y + self.minusoffsety)
		else
            self.image:render_incamera_scaled_from_to(0, (self.size.y + self.minusoffsety) * self.frame + (self.size.y + self.minusoffsety) * 8, self.size.x, self.size.y + self.minusoffsety, self.pos.x, self.pos.y - self.minusoffsety, self.size.x, self.size.y + self.minusoffsety)
        end

    else
        error("Image not loaded for KaizoTomate with ID: " .. tostring(self.image_id))
    end
end


function KaizoTomate:HandleProperty(prop)
    if prop.name == "is_edge_careful" then
        self.is_edge_careful = prop.value
    end

    if prop.name == "dir" then
        self.dir = prop.value
    end

    if self.is_edge_careful then
        self.image_id = 6
    end
end

function KaizoTomate:HandlePlayerCollision(player, collide)
    if collide.down == 4 then
        if player.pressing_jump then
            player.vel.y = -15
        else
            player.vel.y = -7
        end
        self.die = true
    end
end