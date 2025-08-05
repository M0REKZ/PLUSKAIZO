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

require("common/kaizo_image")
require("common/kaizo_collision")
require("common.kaizo_globals")

KaizoSquareResize = setmetatable({}, {__index = KaizoSquare})

KaizoSquareResize.name = "KaizoSquareResize"
KaizoSquareResize.__index = KaizoSquareResize

function KaizoSquareResize:new(x, y, width, height)
    local o = KaizoSquare:new(x,y,width,height)
    o = setmetatable(o,KaizoSquareResize)

    o.render_size = {x = o.size.x, y = o.size.y}
    o.size.y = 16
    o.vel = KaizoLocation:new(velx or 0, vely or 0)
    o.col = KaizoSquareCollision:new(1,0,0,0)

    o.image_id = 17 -- Default image ID for the square
    o.image = nil
    o.active_out_of_camera = true
    
    o.tile_size = {x = 0, y = 0}

    return o
end

function KaizoSquareResize:render()
    if not self.image then
        self.image = GameContext.CurrentLevel:get_entity_image(self.image_id)
        if not self.image then
            local image = KaizoImage:new()
            image:load_entity_image_by_id(o.image_id)
            GameContext.CurrentLevel:add_entity_image(image)
            self.image = image
        end
        if self.image then
            self.tile_size.x = self.image.width/3
            self.tile_size.y = self.image.height/3
        end
    end

    -- Render logic for the square entity
    if(self.image) then
        --print("tile_sizex "..self.tile_size.x.."tile_sizey "..self.tile_size.y)
        self.image:render_incamera_scaled_from_to(0, 0, self.tile_size.x, self.tile_size.y, self.pos.x, self.pos.y,
            self.tile_size.x, self.tile_size.y)
        for i = 1, math.floor(self.render_size.y / self.tile_size.y) - 1, 1 do
            self.image:render_incamera_scaled_from_to(0, self.tile_size.y, self.tile_size.x, self.tile_size.y, self.pos
            .x, self.pos.y + self.tile_size.y * i, self.tile_size.x, self.tile_size.y)
        end
        self.image:render_incamera_scaled_from_to(0, self.tile_size.y * 2, self.tile_size.x, self.tile_size.y, self.pos
        .x, self.pos.y + self.tile_size.y * math.floor(self.render_size.y / self.tile_size.y), self.tile_size.x,
            self.tile_size.y)

        for i = 1, math.floor(self.render_size.x / self.tile_size.x) - 2, 1 do
            self.image:render_incamera_scaled_from_to(self.tile_size.x, 0, self.tile_size.x, self.tile_size.y, self.pos.x + self.tile_size.x * i, self.pos.y,
                self.tile_size.x, self.tile_size.y)
            for j = 1, math.floor(self.render_size.y / self.tile_size.y) - 1, 1 do
                self.image:render_incamera_scaled_from_to(self.tile_size.x, self.tile_size.y, self.tile_size.x, self.tile_size.y,
                    self.pos.x + self.tile_size.x * i, self.pos.y + self.tile_size.y * j, self.tile_size.x, self.tile_size.y)
            end
            self.image:render_incamera_scaled_from_to(self.tile_size.x, self.tile_size.y * 2, self.tile_size.x, self.tile_size.y,
                self.pos.x + self.tile_size.x * i, self.pos.y + self.tile_size.y * math.floor(self.render_size.y / self.tile_size.y),
                self.tile_size.x, self.tile_size.y)
        end

        self.image:render_incamera_scaled_from_to(self.tile_size.x * 2, 0, self.tile_size.x, self.tile_size.y, self.pos.x + self.render_size.x - self.tile_size.x, self.pos.y,
            self.tile_size.x, self.tile_size.y)
        for i = 1, math.floor(self.render_size.y / self.tile_size.y) - 1, 1 do
            self.image:render_incamera_scaled_from_to(self.tile_size.x * 2, self.tile_size.y, self.tile_size.x, self.tile_size.y, self.pos
            .x + self.render_size.x - self.tile_size.x, self.pos.y + self.tile_size.y * i, self.tile_size.x, self.tile_size.y)
        end
        self.image:render_incamera_scaled_from_to(self.tile_size.x * 2, self.tile_size.y * 2, self.tile_size.x, self.tile_size.y, self.pos
        .x + self.render_size.x - self.tile_size.x, self.pos.y + self.tile_size.y * math.floor(self.render_size.y / self.tile_size.y), self.tile_size.x,
            self.tile_size.y)
    else
        error("Image not loaded for KaizoSquare with ID: " .. tostring(self.image_id))
    end
end

function KaizoSquareResize:SaveState()
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
        render_size = self.render_size,
    }
end

function KaizoSquareResize:LoadState(state)
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
    self.render_size = state.render_size
end