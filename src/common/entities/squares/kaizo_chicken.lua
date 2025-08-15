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
require("common.entities.squares.kaizo_falling_egg")
require("common.entities.squares.kaizo_death_effect")

KaizoChicken = setmetatable({}, {__index = KaizoSquare})

KaizoChicken.name = "KaizoChicken"
KaizoChicken.__index = KaizoChicken

function KaizoChicken:new(x, y)
    local o = KaizoSquare:new(x,y)
    o = setmetatable(o,KaizoChicken)

    o.size.x = 64
    o.size.y = 52

    o.col.up = 4
    o.col.down = 2
    o.col.left = 2
    o.col.right = 2

    o.can_collide_square = false
    o.has_qb64_collision = true

    o.image_id = 8 -- Default image ID for the square
    o.image = nil

    o.sec = nil

    o.dir = 0

    o.frame = 0
    o.frametime = 0

    o.egg_timer = 180

    o.did_spawn_sound = false
    o.spawn_sound = nil

    o.death_sound = nil

    return o
end

function KaizoChicken:update()

    if not self.spawn_sound then
        self.spawn_sound = KaizoContext.CurrentLevel:get_sound(6)
        if not self.spawn_sound then
            local sound = KaizoSound:new()
            sound:LoadByID(6)
            KaizoContext.CurrentLevel:add_sound(sound)
            self.spawn_sound = sound
        end
    end

    if not self.death_sound then
        self.death_sound = KaizoContext.CurrentLevel:get_sound(7)
        if not self.death_sound then
            local sound = KaizoSound:new()
            sound:LoadByID(7)
            KaizoContext.CurrentLevel:add_sound(sound)
            self.death_sound = sound
        end
    end

    if not self.did_spawn_sound then
        self.spawn_sound:Stop()
        self.spawn_sound:Play()
        self.did_spawn_sound = true
    end

    if self.die then
        local effect = KaizoDeathEffect:new(self.pos.x, self.pos.y)
        effect.size = self.size
        effect.image_id = 8
        self.ref_layer:add_entity(effect)
        self.death_sound:Stop()
        self.death_sound:Play()
        self:destroy()
        return
    end

    self.sec = KaizoContext.CurrentLevel:get_current_section()

    local player
    player = nil
    local player_layer
    player_layer = nil

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
                player_layer = layer
                break
            end


            :: continue ::
        end
        if player then
            break
        end
    end

    if player then

        if player.pos.x + player.size.x + 4 > self.pos.x + self.size.x then
            if player.pos.y < self.pos.y then
                self.dir = -1
            else
                self.dir = 1
            end
        elseif player.pos.x - 4 < self.pos.x then
            if player.pos.y < self.pos.y then
                self.dir = 1
            else
                self.dir = -1
            end
        else
            self.dir = 0
        end

        self.egg_timer = self.egg_timer -1
    else
        self.dir = 0
        self.egg_timer = 180
    end

    self.vel.x = 5 * self.dir

    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y

    if self.egg_timer <= 0 then
        if player_layer then
            local egg = KaizoFallingEGG:new((self.pos.x + self.size.x/2)-11,self.pos.y + self.size.y) 
            egg.vel.x = self.vel.x
            egg.active_out_of_camera = true
            player_layer:add_entity(egg)
        end
        self.egg_timer = 180
    end
    
end

function KaizoChicken:render()

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
		
		if(self.frame > 1) then
			self.frame = 0
        end
		
		if(self.dir < 0) then
            self.image:render_incamera_scaled_from_to(0, self.size.y * self.frame, self.size.x, self.size.y, self.pos.x, self.pos.y, self.size.x, self.size.y)
		else
            self.image:render_incamera_scaled_from_to(0, self.size.y * self.frame, self.size.x, self.size.y, self.pos.x + self.size.x, self.pos.y, self.size.x * -1, self.size.y)
        end

    else
        error("Image not loaded for KaizoChicken with ID: " .. tostring(self.image_id))
    end
end

function KaizoChicken:HandlePlayerCollision(player, collide)
    
    if collide.down == 4 then
        if player.pressing_jump then
            player.vel.y = -15
        else
            player.vel.y = -7
        end
        self.die = true
    end
end

function KaizoChicken:SaveState()
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
        die = self.die,
        dir = self.dir,
        frame = self.frame,
        frametime = self.frametime,
        egg_timer = self.egg_timer,
        did_spawn_sound = self.did_spawn_sound,
        active_out_of_camera = self.active_out_of_camera,
    }
end

function KaizoChicken:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.pos = state.pos
    self.size = state.size
    self.vel = state.vel
    self.col = state.col
    self.image_id = state.image_id
    self.can_collide_square = state.can_collide_square
    self.has_collision_square = state.has_collision_square

    self.die = state.die
    self.dir = state.dir
    self.frame = state.frame
    self.frametime = state.frametime
    self.egg_timer = state.egg_timer
    self.did_spawn_sound = state.did_spawn_sound
    self.active_out_of_camera = state.active_out_of_camera
end