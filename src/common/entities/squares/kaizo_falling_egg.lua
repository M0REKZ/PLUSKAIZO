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

KaizoFallingEGG = setmetatable({}, {__index = KaizoSquare})

KaizoFallingEGG.name = "KaizoFallingEGG"
KaizoFallingEGG.__index = KaizoFallingEGG

function KaizoFallingEGG:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoFallingEGG)

    o.size.x = 22
    o.size.y = 25

    o.col.up = 4
    o.col.down = 4
    o.col.left = 4
    o.col.right = 4


    o.image_id = 10 -- Default image ID for the square
    o.image = nil

    o.sec = nil

    o.death_sound = nil

    return o
end

function KaizoFallingEGG:update()

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
        self:destroy()
        if self.death_sound then
            self.death_sound:Stop()
            self.death_sound:Play()
        end
        return
    end

    if self.vel.y < 15 then --max fall vel
        self.vel.y = self.vel.y + 1
    end

    local collide

    collide = {up = 0, down = 0, left = 0, right = 0}

    self.sec = KaizoContext.CurrentLevel:get_current_section()

    for _, layer in ipairs(self.sec.Layers) do
        local temp_tiles = {}
        local tilepos = {}

        tilepos[1] = {x = self.pos.x + self.vel.x, y = self.pos.y + self.vel.y}
        tilepos[2] = {x = self.pos.x + self.vel.x + self.size.x, y = self.pos.y + self.vel.y + self.size.y}
        tilepos[3] = {x = self.pos.x + self.vel.x + self.size.x, y = self.pos.y + self.vel.y}
        tilepos[4] = {x = self.pos.x + self.vel.x, y = self.pos.y + self.vel.y + self.size.y}

        temp_tiles[1] = layer:get_tile_id(tilepos[1].x, tilepos[1].y)
        temp_tiles[2] = layer:get_tile_id(tilepos[2].x, tilepos[2].y)
        temp_tiles[3] = layer:get_tile_id(tilepos[3].x, tilepos[3].y)
        temp_tiles[4] = layer:get_tile_id(tilepos[4].x, tilepos[4].y)

        if self.is_edge_careful then
            if not (TileToCollision(temp_tiles[2]).up == 1) ~= not (TileToCollision(temp_tiles[4]).up == 1) then
                self.dir = self.dir * -1
            end
        end

        for num, tile in ipairs(temp_tiles) do
            if not (tile == 0) then
                collide = DetectVerticalSquareCollision( self.pos.x, self.pos.y, self.vel.y, self.size.x, self.size.y, tilepos[num].x - (tilepos[num].x % 32), tilepos[num].y - (tilepos[num].y % 32), 32, 32, TileToCollision(tile))
                if collide.up == 1 or collide.up == 5 then
                    self.die = true
                    return
                end
                
                collide = {up = 0, down = 0, left = 0, right = 0}
            end
        end

        for _, ent in ipairs(layer.Entities) do
            if ent == self then
                goto continue
            end

            if ent.marked_for_deletion then
                goto continue
            end

            if not ent.active then
                goto continue
            end

            if ent.has_collision_square then
                collide = DetectVerticalSquareCollision(self.pos.x, self.pos.y, self.vel.y, self.size.x, self.size.y, ent.pos.x, ent.pos.y, ent.size.x, ent.size.y, ent.col)
                if collide.up == 1 or collide.up == 5 then
                    self.die = true
                    return
                end
                collide = {up = 0, down = 0, left = 0, right = 0}
            end

            

            ::continue::
        end
    end

    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    
end

function KaizoFallingEGG:render()

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
		
		if(self.vel.x <= 0) then
            self.image:render_incamera_scaled_from_to(0, 0, self.size.x, self.size.y, self.pos.x, self.pos.y, self.size.x, self.size.y)
		else
            self.image:render_incamera_scaled_from_to(0, 0, self.size.x, self.size.y, self.pos.x + self.size.x, self.pos.y, self.size.x * -1, self.size.y)
        end

    else
        error("Image not loaded for KaizoFallingEGG with ID: " .. tostring(self.image_id))
    end
end

function KaizoFallingEGG:HandlePlayerCollision(player, collide)
    
    player.die = true
    self.die = true
end

function KaizoFallingEGG:SaveState()
    return {
        name = self.name,
        marked_for_deletion = self.marked_for_deletion,
        pos = {x = self.pos.x, y = self.pos.y},
        size = {x = self.size.x, y = self.size.y},
        vel = {x = self.vel.x, y = self.vel.y},
        col = {up = self.col.up, down = self.col.down, left = self.col.left, right = self.col.right},
        image_id = self.image_id,
        can_collide_square = self.can_collide_square,
        has_collision_square = self.has_collision_square,
        active = self.active,
        active_out_of_camera = self.active_out_of_camera,
    }
end

function KaizoFallingEGG:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.pos = state.pos
    self.size = state.size
    self.vel = state.vel
    self.col = state.col
    self.image_id = state.image_id
    self.can_collide_square = state.can_collide_square
    self.has_collision_square = state.has_collision_square
    self.active = state.active

    self.active_out_of_camera = state.active_out_of_camera
end