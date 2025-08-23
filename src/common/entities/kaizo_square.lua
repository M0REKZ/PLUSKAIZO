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

KaizoSquare = {name = "KaizoSquare"}
KaizoSquare.__index = KaizoSquare

function KaizoSquare:new(x, y, width, height, velx, vely)
    local o = setmetatable({},KaizoSquare)

    o.marked_for_deletion = false

    o.pos = KaizoLocation:new(x, y)
    o.size = KaizoLocation:new(width or 32, height or 32)
    o.vel = KaizoLocation:new(velx or 0, vely or 0)
    o.col = KaizoSquareCollision:new(1,1,1,1)

    o.image_id = 1 -- Default image ID for the square
    o.image = nil
    o.can_collide_square = true
    o.has_collision_square = true
    o.is_on_background = false

    o.ref_layer = nil

    return o
end

function KaizoSquare:update()

    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    
end

function KaizoSquare:render()

    if not self.image then
        self.image = KaizoContext.CurrentLevel:get_entity_image(self.image_id)
        if not self.image then
            local image = KaizoImage:new()
            image:load_entity_image_by_id(o.image_id)
            KaizoContext.CurrentLevel:add_entity_image(image)
            self.image = image
        end
    end

    -- Render logic for the square entity
    if(self.image) then
        self.image:render_incamera_scaled_to(self.pos.x, self.pos.y, self.size.x, self.size.y)
    else
        error("Image not loaded for KaizoSquare with ID: " .. tostring(self.image_id))
    end
end

function KaizoSquare:destroy()
    self.marked_for_deletion = true
end

function KaizoSquare:SaveState()
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
    }
end

function KaizoSquare:LoadState(state)
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
end