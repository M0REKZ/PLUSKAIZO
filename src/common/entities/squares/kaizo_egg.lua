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

KaizoEGG = setmetatable({}, {__index = KaizoSquare})

KaizoEGG.name = "KaizoEGG"

KaizoEGG.__index = KaizoEGG

function KaizoEGG:new(x,y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoEGG)

    o.col.up = 3
    o.col.down = 2
    o.col.left = 2
    o.col.right = 2

    o.size.x = 22
    o.size.y = 25

    o.image_id = 3 -- Default image ID for EGG
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
    o.is_coward = false

    o.edge_careful_corners = {left = true,right = true}

    o.can_load_level_properties = true
    o.has_qb64_collision = true

    o.death_sound = KaizoContext.CurrentLevel:get_sound(1)

    if not o.death_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(1)
        KaizoContext.CurrentLevel:add_sound(sound)
        o.death_sound = sound
    end

    return o
end

function KaizoEGG:update()
    if self.die then
        self:destroy()
        if self.death_sound then
            self.death_sound:Stop()
            self.death_sound:Play()
        end
        return
    end

    self.sec = KaizoContext.CurrentLevel:get_current_section()

    if self.vel.y < 15 then --max fall vel
        self.vel.y = self.vel.y + 1
    end

    if self.is_coward then
        local player
        player = nil
        for _, layer in ipairs(self.sec.Layers) do
            for _, ent in ipairs(layer.Entities) do
                if ent == self then
                    goto continue
                end

                if ent.marked_for_deletion then
                    goto continue
                end

                if ent.is_player then
                    player = ent
                    break
                end


                :: continue ::
            end
            if player then
                break
            end
        end

        if player then
            if player.pos.y + player.size.y < self.pos.y then
                if player.pos.x + player.size.x/2 < self.pos.x + self.size.x/2 then
                    self.dir = 7
                else
                    self.dir = -7

                end
            else
                if self.dir > 1 then
                    self.dir = 1
                elseif self.dir < -1 then
                    self.dir = -1
                end
            end
        end
    end

    self.vel.x = self.dir

    self:do_collision()

    if self.is_edge_careful then
        if ((not self.edge_careful_corners.left) and self.vel.x < 0) then
            self.dir = math.abs(self.dir)
        elseif ((not self.edge_careful_corners.right) and self.vel.x > 0) then
            self.dir = math.abs(self.dir) * -1
        end
    end

    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
end

function KaizoEGG:render()

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
            self.image:render_incamera_scaled_from_to(0, self.size.y * self.frame, self.size.x, self.size.y, self.pos.x, self.pos.y, self.size.x, self.size.y)
		else
            self.image:render_incamera_scaled_from_to(0, self.size.y * self.frame + self.size.y * 8, self.size.x, self.size.y, self.pos.x, self.pos.y, self.size.x, self.size.y)
        end

    else
        error("Image not loaded for KaizoSquare with ID: " .. tostring(self.image_id))
    end
end

function KaizoEGG:destroy()
    self.marked_for_deletion = true
end

function KaizoEGG:do_collision()
     --reset some vars before collision
    local collide = {}
    local collidepoint = nil
    local verticalmovement = 0
    self.grounded = false
    self.edge_careful_corners.left = false
    self.edge_careful_corners.right = false
    
    for _, layer in ipairs(self.sec.Layers) do
        local temp_tiles = {}

        temp_tiles[1] = {x = self.pos.x + self.vel.x, y = self.pos.y + self.vel.y}
        temp_tiles[2] = {x = self.pos.x + self.vel.x + self.size.x, y = self.pos.y + self.vel.y + self.size.y}
        temp_tiles[3] = {x = self.pos.x + self.vel.x + self.size.x, y = self.pos.y + self.vel.y}
        temp_tiles[4] = {x = self.pos.x + self.vel.x, y = self.pos.y + self.vel.y + self.size.y}

        temp_tiles[1].id = layer:get_tile_id(temp_tiles[1].x, temp_tiles[1].y)
        temp_tiles[2].id = layer:get_tile_id(temp_tiles[2].x, temp_tiles[2].y)
        temp_tiles[3].id = layer:get_tile_id(temp_tiles[3].x, temp_tiles[3].y)
        temp_tiles[4].id = layer:get_tile_id(temp_tiles[4].x, temp_tiles[4].y)

        temp_tiles[1].w = 32
        temp_tiles[1].h = 32

        temp_tiles[2].w = 32
        temp_tiles[2].h = 32

        temp_tiles[3].w = 32
        temp_tiles[3].h = 32

        temp_tiles[4].w = 32
        temp_tiles[4].h = 32

        if GetSlopeInfo(temp_tiles[4].id) then --handle slope first
            local temp = nil
            temp = temp_tiles[4]
            temp_tiles[4] = temp_tiles[2]
            temp_tiles[2] = temp
        end

        for num, tile in ipairs(temp_tiles) do

            tile.x = tile.x - (tile.x % 32)
            tile.y = tile.y - (tile.y % 32)
            if not (tile == 0) then
                collide, collidepoint = DetectVerticalSquareCollision( self.pos.x, self.pos.y, self.vel.y, self.size.x, self.size.y, tile.x , tile.y , tile.w, tile.h, TileToCollision(tile.id), tile.id)
                self:handle_collision(collide, {x = tile.x, y = collidepoint}, {x = tile.w, y = tile.h})
                collide = nil
                collidepoint = nil
                collide, collidepoint, verticalmovement = DetectHorizontalSquareCollision( self.pos.x, self.pos.y, self.vel.x, self.size.x, self.size.y, tile.x, tile.y, tile.w, tile.h, TileToCollision(tile.id), tile.id)
                self.pos.y = self.pos.y + verticalmovement
                self:handle_collision(collide, {x = collidepoint, y = tile.y}, {x = tile.w, y = tile.h})
                collide = nil
                collidepoint = nil
                verticalmovement = 0
            end
            ::continue::
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
                if ent.has_qb64_collision then
                    collide = DetectSquareToSquareCollisionQB64OldNew(self.pos.x, self.pos.y, self.pos.x + self.vel.x, self.pos.y + self.vel.y, self.size.x, self.size.y, ent.pos.x, ent.pos.y, ent.size.x, ent.size.y, ent.col)
                    self:handle_collision(collide, ent.pos, ent.size, ent)
                    collide = {up = 0, down = 0, left = 0, right = 0}
                else
                    collide, collidepoint = DetectVerticalSquareCollision( self.pos.x, self.pos.y, self.vel.y, self.size.x, self.size.y, ent.pos.x , ent.pos.y , ent.size.x, ent.size.y, ent.col)
                    self:handle_collision(collide, {x = ent.pos.x, y = collidepoint}, {x = ent.size.x, y = ent.size.y}, ent)
                    collide = nil
                    collidepoint = nil
                    collide, collidepoint, verticalmovement = DetectHorizontalSquareCollision( self.pos.x, self.pos.y, self.vel.x, self.size.x, self.size.y, ent.pos.x, ent.pos.y, ent.size.x, ent.size.y, ent.col)
                    self.pos.y = self.pos.y + verticalmovement
                    self:handle_collision(collide, {x = collidepoint, y = ent.pos.y}, {x = ent.size.x, y = ent.size.y}, ent)
                    collide = nil
                    collidepoint = nil
                    verticalmovement = 0
                end
            end

            

            ::continue::
        end
    end
end

function KaizoEGG:handle_collision(collide, pos2, size2, ent)

    if collide.up == 6 or collide.down == 6 or collide.left == 6 or collide.right == 6 then
        local temp = nil
        temp = ent:HandleEntityCollision(self, collide)
        if temp then
            collide = temp
        end
    end

    if (collide.down == 1 or collide.down == 2) and self.is_edge_careful then
        if pos2.x < self.pos.x + self.size.x/2 then
            self.edge_careful_corners.left = true
        end
        if pos2.x + size2.x > self.pos.x + self.size.x/2 then
            self.edge_careful_corners.right = true
        end
    end

    if (collide.down == 1 or (collide.down == 2)) and self.vel.y > 0 then
        self.vel.y = 0
        self.pos.y = pos2.y - self.size.y
        self.jumped = false         --i can jump now
        self.grounded = true
    elseif not (collide.down == 1 or (collide.down == 2)) and not self.grounded then
        self.grounded = false
    end

    if (collide.up == 1 or (collide.up == 2)) and self.vel.y < 0 then
        self.vel.y = 0
        self.pos.y = pos2.y + size2.y
    end

    if (collide.left == 1 or (collide.left == 2)) and self.vel.x < 0 then
        self.vel.x = 0
        self.pos.x = pos2.x + size2.x
        if self.dir < 2 and self.dir > -2 then
            self.dir = self.dir * -1
        end
    end

    if (collide.right == 1 or (collide.right == 2)) and self.vel.x > 0 then
        self.vel.x = 0
        self.pos.x = pos2.x - self.size.x
        if self.dir < 2 and self.dir > -2 then
            self.dir = self.dir * -1
        end
    end

    if collide.up == 5 or collide.down == 5 or collide.left == 5 or collide.right == 5 then
        self.die = true
    end
end

function KaizoEGG:SaveState()
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
        is_player = self.is_player,
        going_left = self.going_left,
        going_right = self.going_right,
        jumped = self.jumped,
        die = self.die,
        grounded = self.grounded,
        can_die = self.can_die,
        dir = self.dir,
        frame = self.frame,
        frametime = self.frametime,
        is_npc = self.is_npc,
        active = self.active,
        is_edge_careful = self.is_edge_careful,
        is_coward = self.is_coward,
        edge_careful_corners = self.edge_careful_corners,
    }
end

function KaizoEGG:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.pos = state.pos
    self.size = state.size
    self.vel = state.vel
    self.col = state.col
    self.image_id = state.image_id
    self.can_collide_square = state.can_collide_square
    self.has_collision_square = state.has_collision_square

    self.is_player = state.is_player
    self.is_npc = state.is_npc
    self.going_left = state.going_left
    self.going_right = state.going_right
    self.jumped = state.jumped
    self.die = state.die
    self.grounded = state.grounded
    self.can_die = state.can_die

    self.dir = state.dir
    self.frame = state.frame
    self.frametime = state.frametime
    self.active = state.active
    self.is_edge_careful = state.is_edge_careful
    self.is_coward = state.is_coward

    self.edge_careful_corners = state.edge_careful_corners
end

function KaizoEGG:HandleProperty(prop)
    if prop.name == "is_edge_careful" then
        self.is_edge_careful = prop.value
    end

    if prop.name == "is_coward" then
        self.is_coward = prop.value
    end

    if self.is_coward then
        self.image_id = 11
    elseif self.is_edge_careful then
        self.image_id = 4
    end
end