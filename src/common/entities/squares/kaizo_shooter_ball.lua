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

KaizoShooterBall = setmetatable({}, {__index = KaizoSquare})

KaizoShooterBall.name = "KaizoShooterBall"

KaizoShooterBall.__index = KaizoShooterBall

KaizoShooterBall.editor_properties = {}
KaizoShooterBall.editor_properties[1] = "dir"


function KaizoShooterBall:new(x,y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoShooterBall)

    o.col.up = 4
    o.col.down = 2
    o.col.left = 2
    o.col.right = 2

    o.size.x = 26
    o.size.y = 26

    o.image_id = 25
    o.image = nil
    o.can_collide_square = true
    o.has_collision_square = true
    o.is_player = false
    o.is_npc = true
    o.going_left = false
    o.going_right = false
    o.die = false
    o.grounded = false
    o.can_die = true
    o.dir = -1
    o.looking = -1
    o.frame = 0
    o.frametime = 0
    o.sec = 0
    o.is_coward = false

    o.edge_careful_corners = {left = true,right = true}

    o.can_load_level_properties = true
    o.has_qb64_collision = true

    o.death_sound = nil
    o.shoot_sound = nil

    o.time_to_fire = 200

    return o
end

function KaizoShooterBall:update()

    if not self.death_sound then
        self.death_sound = KaizoContext.CurrentLevel:get_sound(10)
        if not self.death_sound then
            local sound = KaizoSound:new()
            sound:LoadByID(10)
            KaizoContext.CurrentLevel:add_sound(sound)
            self.death_sound = sound
        end
    end

    if not self.shoot_sound then
        self.shoot_sound = KaizoContext.CurrentLevel:get_sound(11)
        if not self.shoot_sound then
            local sound = KaizoSound:new()
            sound:LoadByID(11)
            KaizoContext.CurrentLevel:add_sound(sound)
            self.shoot_sound = sound
        end
    end

    if self.die then
        local effect = KaizoDeathEffect:new((self.pos.x + self.size.x/2) - 18, (self.pos.y + self.size.y/2) - 14)
        effect.size = {x = 36, y = 29}
        effect.image_id = 26
        self.ref_layer:add_entity(effect)
        if self.death_sound then
            self.death_sound:Stop()
            self.death_sound:Play()
        end
        self:destroy()
        return
    end

    self.sec = KaizoContext.CurrentLevel:get_current_section()

    if self.vel.y < 15 then --max fall vel
        self.vel.y = self.vel.y + 1
    end

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
            if player.pos.x + player.size.x/2 < self.pos.x + self.size.x/2 then
                self.looking = -1
            else
                self.looking = 1
            end
        end

    self.vel.x = self.dir

    self:do_collision()

        if not (not self.edge_careful_corners.left and not self.edge_careful_corners.right) then
            if ((not self.edge_careful_corners.left) and self.vel.x < 0) then
                self.dir = math.abs(self.dir)
            elseif ((not self.edge_careful_corners.right) and self.vel.x > 0) then
                self.dir = math.abs(self.dir) * -1
            end
        end

    self.time_to_fire = self.time_to_fire - 1

    if self.time_to_fire <= 50 then
        self.vel.x = 0;
        if self.time_to_fire <= 0 then
            if self.shoot_sound then
                self.shoot_sound:Stop()
                self.shoot_sound:Play()
            end
            local exitloop = false
            local closest_entity = nil
            for _, layer in ipairs(self.sec.Layers) do
                for _, ent in ipairs(layer.Entities) do
                    if ent == self then
                        goto continue
                    end

                    if ent.marked_for_deletion then
                        goto continue
                    end

                    
                    if ent.pos.y <= self.pos.y + self.size.y / 2 and ent.pos.y + ent.size.y >= self.pos.y + self.size.y / 2 then
                        if self.looking == -1 then
                            if ent.pos.x + ent.size.x <= self.pos.x then
                                local collided = false
                                for i = self.pos.x, ent.pos.x + ent.size.x , -32 do
                                    local tile_id = layer:get_tile_id(i, self.pos.y + self.size.y / 2)
                                    if TileToCollision(tile_id).right == 1 then
                                        collided = true
                                        break
                                    end
                                end
                                if not collided then
                                    if not closest_entity then
                                        closest_entity = ent
                                    end

                                    if self.pos.x - (ent.pos.x + ent.size.x) < self.pos.x - (closest_entity.pos.x + closest_entity.size.x) then
                                        closest_entity = ent
                                    end
                                    --exitloop = true
                                end
                            end
                        else
                            if ent.pos.x >= self.pos.x + self.size.x then
                                local collided = false
                                for i = self.pos.x + self.size.x, ent.pos.x , 32 do
                                    local tile_id = layer:get_tile_id(i, self.pos.y + self.size.y / 2)
                                    if TileToCollision(tile_id).right == 1 then
                                        collided = true
                                        break
                                    end
                                end
                                if not collided then
                                    if not closest_entity then
                                        closest_entity = ent
                                    end

                                    if ent.pos.x - (self.pos.x + self.size.x) < closest_entity.pos.x - (self.pos.x + self.size.x) then
                                        closest_entity = ent
                                    end
                                    --exitloop = true
                                end
                            end
                        end
                    end


                    :: continue ::
                end
                if exitloop then
                    break
                end
            end
            if closest_entity then
                closest_entity.die = true
            end
            self.time_to_fire = 200
        end
    end

    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y

    
end

local function RenderFeet(self, left)
    local xoffset = 12
    if left then
        xoffset = -4
    end

    local frame = self.frame
    if left then
        frame = 7 - self.frame
    end

    local mult = 1
    if left then
        mult = -1
    end

    if self.dir > 0 then
        frame = 7 - frame
    end

    if self.vel.x == 0 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 7, 17, 9)
        return
    end

    if frame == 0 then
        xoffset = xoffset
    elseif frame == 1 then
        xoffset = xoffset - 1 * mult
    elseif frame == 2 then
        xoffset = xoffset - 2 * mult
    elseif frame == 3 then
        xoffset = xoffset - 3 * mult
    elseif frame == 4 then
        xoffset = xoffset - 4 * mult
    elseif frame == 5 then
        xoffset = xoffset - 3 * mult
    elseif frame == 6 then
        xoffset = xoffset - 2 * mult
    else
        xoffset = xoffset - 1 * mult
    end

    if frame == 0 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 9, 17, 9)
    elseif frame == 1 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 9, 17, 9)
    elseif frame == 2 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 9, 17, 9)
    elseif frame == 3 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 8, 17, 9)
    elseif frame == 4 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 7, 17, 9)
    elseif frame == 5 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 7, 17, 9)
    elseif frame == 6 then
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 7, 17, 9)
    else
        self.image:render_incamera_scaled_from_to(33, 0, 17, 9, self.pos.x + xoffset, self.pos.y + self.size.y - 8, 17, 9)
    end
end

function KaizoShooterBall:render()

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


        if self.dir < 0 then
            RenderFeet(self, true)
        elseif self.dir > 0 then
            RenderFeet(self, false)
        else
            if self.looking == -1 then
                RenderFeet(self, true)
            else
                RenderFeet(self, false)
            end
        end

        --pistol
        if self.looking == -1 then
            self.image:render_incamera_scaled_from_to(0, 24, 22, 16, self.pos.x - 20, self.pos.y + 6, 22, 16)
        else
            self.image:render_incamera_scaled_from_to(0, 24, 22, 16, self.pos.x + 20 + 22, self.pos.y + 6, -22, 16)
        end
        if self.time_to_fire == 1 then
            --fire effect
            if self.looking == -1 then
                self.image:render_incamera_scaled_from_to(22, 0, 11, 11, self.pos.x - 26, self.pos.y + 3, 11, 11)
            else
                self.image:render_incamera_scaled_from_to(22, 0, 11, 11, self.pos.x + 26 + 22, self.pos.y + 3, -11, 11)
            end
        end

		--body
        self.image:render_incamera_scaled_from_to(23, 15, self.size.x, self.size.y, self.pos.x, self.pos.y, self.size.x, self.size.y)
        
        --eyes
        local yoffseteyes = 0
        if self.time_to_fire <= 50 then
            yoffseteyes = 12
        end
        if self.looking == -1 then
            self.image:render_incamera_scaled_from_to(0, yoffseteyes, 20, 11, self.pos.x, self.pos.y + 8, 20, 11)
        else
            self.image:render_incamera_scaled_from_to(0, yoffseteyes, 20, 11, self.pos.x + self.size.x, self.pos.y + 8, -20, 11)
        end

        if self.dir < 0 then
            RenderFeet(self, false)
        elseif self.dir > 0 then
            RenderFeet(self, true)
        else
            if self.looking == -1 then
                RenderFeet(self, false)
            else
                RenderFeet(self, true)
            end
        end

    else
        error("Image not loaded for KaizoSquare with ID: " .. tostring(self.image_id))
    end
end

function KaizoShooterBall:destroy()
    self.marked_for_deletion = true
end

function KaizoShooterBall:do_collision()
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

function KaizoShooterBall:handle_collision(collide, pos2, size2, ent)

    if ent and ent.is_projectile and (collide.up ~= 0 or collide.down ~= 0 or collide.left ~= 0 or collide.right ~= 0) then
        self.die = true
    end

    if collide.up == 6 or collide.down == 6 or collide.left == 6 or collide.right == 6 then
        local temp = nil
        temp = ent:HandleEntityCollision(self, collide)
        if temp then
            collide = temp
        end
    end

    if (collide.down == 1 or collide.down == 2) then
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

function KaizoShooterBall:SaveState()
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
        die = self.die,
        grounded = self.grounded,
        can_die = self.can_die,
        dir = self.dir,
        frame = self.frame,
        frametime = self.frametime,
        is_npc = self.is_npc,
        active = self.active,
        edge_careful_corners = self.edge_careful_corners,
        time_to_fire = self.time_to_fire,
    }
end

function KaizoShooterBall:LoadState(state)
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
    self.die = state.die
    self.grounded = state.grounded
    self.can_die = state.can_die

    self.dir = state.dir
    self.frame = state.frame
    self.frametime = state.frametime
    self.active = state.active

    self.edge_careful_corners = state.edge_careful_corners
    self.time_to_fire = state.time_to_fire
end

function KaizoShooterBall:HandleProperty(prop)
    if prop.name == "dir" then
        self.dir = prop.value
    end
end

function KaizoShooterBall:HandlePlayerCollision(player, collide)
    if collide.down == 4 then
        if player.pressing_jump then
            player.vel.y = -15
        else
            player.vel.y = -7
        end
        if self.death_sound then
            self.death_sound:Stop()
            self.death_sound:Play()
        end
    end
end