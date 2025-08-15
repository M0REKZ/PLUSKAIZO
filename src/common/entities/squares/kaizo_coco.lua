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

KaizoCoco= setmetatable({}, {__index = KaizoEGG})
KaizoCoco.name = "KaizoCoco"

KaizoCoco.__index = KaizoCoco

KaizoCoco.editor_properties = {}
KaizoCoco.editor_properties[1] = "is_edge_careful"
KaizoCoco.editor_properties[2] = "is_dead"
KaizoCoco.editor_properties[3] = "dir"

function KaizoCoco:new(x,y)
    local o = KaizoEGG:new(x,y)
    o = setmetatable(o,KaizoCoco)

    o.col.up = 4
    o.col.down = 2
    o.col.left = 2
    o.col.right = 2

    o.size.x = 22
    o.size.y = 25 - 7

    o.minusoffsety = 7

    o.image_id = 21 -- Default image ID for KaizoCoco
    o.image_dead_id = 23
    o.image = nil
    o.image_alive = nil
    o.image_dead = nil
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

    o.is_projectile = false
    o.is_dead = false
    o.player_damage_timeout = 0

    o.can_load_level_properties = true

    o.death_sound = KaizoContext.CurrentLevel:get_sound(7)

    if not o.death_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(5)
        KaizoContext.CurrentLevel:add_sound(sound)
        o.death_sound = sound
    end

    return o
end

function KaizoCoco:update()
    if self.player_damage_timeout > 0 then
        self.player_damage_timeout = self.player_damage_timeout - 1
    end

    KaizoEGG.update(self)
end

function KaizoCoco:render()

    if not self.image_alive then
        self.image_alive = KaizoContext.CurrentLevel:get_entity_image(self.image_id)
        if not self.image_alive then
            if not self.image_alive then
                local image = KaizoImage:new()
                image:load_entity_image_by_id(self.image_id)
                KaizoContext.CurrentLevel:add_entity_image(image)
                self.image_alive = image
            end
        end
    end

    if not self.image_dead then
        self.image_dead = KaizoContext.CurrentLevel:get_entity_image(self.image_dead_id)
        if not self.image_dead then
            if not self.image_dead then
                local image = KaizoImage:new()
                image:load_entity_image_by_id(self.image_dead_id)
                KaizoContext.CurrentLevel:add_entity_image(image)
                self.image_dead = image
            end
        end
    end

    if self.is_dead then
        self.image = self.image_dead
    else
        self.image = self.image_alive
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
        error("Image not loaded for KaizoCoco with ID: " .. tostring(self.image_id))
    end
end


function KaizoCoco:HandleProperty(prop)
    if prop.name == "is_edge_careful" then
        self.is_edge_careful = prop.value
    end

    if prop.name == "dir" then
        self.dir = prop.value
    end

    if prop.name == "is_dead" then
        self.is_dead = prop.value
    end


    if self.is_edge_careful then
        self.image_id = 20
        self.image_dead_id = 22
    end
end

function KaizoCoco:HandlePlayerCollision(player, collide)
    if collide.down == 4 then
        if player.pressing_jump then
            player.vel.y = -15
        else
            player.vel.y = -7
        end
        if self.dir == 0 then
            self.dir = player.looking * 7
            self.is_projectile = true
            
        else
            self.dir = 0
            self.is_projectile = false
        end
        if (not player.is_spin_jump) and self.death_sound then
            self.death_sound:Stop()
            self.death_sound:Play()
        end
        if player.is_spin_jump then --die for real with spin jump
            self.die = true
        end
        self.col.up = 4
        self.col.down = 0
        self.col.left = 4
        self.col.right = 4
        self.is_edge_careful = false
        self.is_coward = false
        self.is_dead = true
    elseif collide.left == 4 then
        if self.dir == 0 then
            if self.death_sound then
                self.death_sound:Stop()
                self.death_sound:Play()
            end
            self.dir = -7
            self.is_projectile = true
            self.player_damage_timeout = 50
        elseif self.player_damage_timeout == 0 then
            self.col.left = 2
            self.col.right = 2
        end
    
    elseif collide.right == 4 then
        if self.dir == 0 then
            if self.death_sound then
                self.death_sound:Stop()
                self.death_sound:Play()
            end

            self.dir = 7
            self.is_projectile = true
            self.player_damage_timeout = 50
            
        elseif self.player_damage_timeout == 0 then
            self.col.left = 2
            self.col.right = 2
        end
    
    end
end

function KaizoCoco:SaveState()
    local state = KaizoEGG.SaveState(self)

    state.is_projectile = self.is_projectile
    state.is_dead = self.is_dead
    state.image_dead_id = self.image_dead_id
    state.player_damage_timeout = self.player_damage_timeout

    return state
end

function KaizoCoco:LoadState(state)
    KaizoEGG.LoadState(self,state)

    self.is_projectile = state.is_projectile
    self.is_dead = state.is_dead
    self.image_dead_id = state.image_dead_id or self.image_dead_id
    self.player_damage_timeout = state.player_damage_timeout or self.player_damage_timeout
    
end

function KaizoCoco:handle_collision(collide, pos2, size2, ent)

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

    if (collide.down == 1 or collide.down == 2) and self.is_edge_careful then
        if pos2.x < self.pos.x + self.size.x/2 then
            self.edge_careful_corners.left = true
        end
        if pos2.x + size2.x > self.pos.x + self.size.x/2 then
            self.edge_careful_corners.right = true
        end
    end

    if (collide.down == 1 or ((not self.is_dead) and collide.down == 2)) and self.vel.y > 0 then
        self.vel.y = 0
        self.pos.y = pos2.y - self.size.y
        self.jumped = false         --i can jump now
        self.grounded = true
    elseif not (collide.down == 1 or (collide.down == 2)) and not self.grounded then
        self.grounded = false
    end

    if (collide.up == 1 or ((not self.is_dead) and collide.up == 2)) and self.vel.y < 0 then
        self.vel.y = 0
        self.pos.y = pos2.y + size2.y
    end

    if (collide.left == 1 or ((not self.is_dead) and collide.left == 2)) and self.vel.x < 0 then
        self.vel.x = 0
        self.pos.x = pos2.x + size2.x
        if self.is_dead or (self.dir < 2 and self.dir > -2) then
            self.dir = self.dir * -1
        end
    end

    if (collide.right == 1 or ((not self.is_dead) and collide.right == 2)) and self.vel.x > 0 then
        self.vel.x = 0
        self.pos.x = pos2.x - self.size.x
        if self.is_dead or (self.dir < 2 and self.dir > -2) then
            self.dir = self.dir * -1
        end
    end

    if collide.up == 5 or collide.down == 5 or collide.left == 5 or collide.right == 5 then
        self.die = true
    end
end