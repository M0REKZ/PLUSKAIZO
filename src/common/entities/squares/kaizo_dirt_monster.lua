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

KaizoDirtMonster = setmetatable({}, {__index = KaizoEGG})
KaizoDirtMonster.name = "KaizoDirtMonster"

KaizoDirtMonster.__index = KaizoDirtMonster

KaizoDirtMonster.editor_properties = {}
KaizoDirtMonster.editor_properties[1] = "dir"

function KaizoDirtMonster:new(x,y)
    local o = KaizoEGG:new(x,y)
    o = setmetatable(o,KaizoDirtMonster)

    o.col.up = 4
    o.col.down = 0
    o.col.left = 0
    o.col.right = 0

    o.size.x = 23
    o.size.y = 18

    o.image_id = 12 -- Default image ID for KaizoDirtMonster
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
    o.hidden = true

    o.can_load_level_properties = true

    o.death_sound = KaizoContext.CurrentLevel:get_sound(5)
    o.unhidingframe = 0
    o.unhidingframetime = 0

    if not o.death_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(5)
        KaizoContext.CurrentLevel:add_sound(sound)
        o.death_sound = sound
    end

    return o
end

function KaizoDirtMonster:update()

    if self.hidden then

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
            if IsPointInsideSquare(player.pos.x + player.size.x/2,player.pos.y + player.size.y/2,self.pos.x - 128,self.pos.y - 128,self.pos.x + self.size.x + 128,self.pos.y + self.size.y + 128) then
                self.hidden = false
                self.col.left = 2
                self.col.right = 2
                self.col.down = 2
            end
        end
    else
        if self.unhidingframe < 5 then
            self.unhidingframetime = self.unhidingframetime + 1

            if self.unhidingframetime > 2 then
                self.unhidingframe = self.unhidingframe + 1
                self.unhidingframetime = 0
            end
        else
            KaizoEGG.update(self) -- call base class
        end
        
    end
    
end

function KaizoDirtMonster:render()

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

        if self.unhidingframe >= 5 then
            self.frametime = self.frametime + 1

            if (self.frametime > 4) then
                self.frame = self.frame + 1
                self.frametime = 0
            end

            if (self.frame > 2) then
                self.frame = 1
            end
        end
		
        if self.unhidingframe < 5 then
            if self.unhidingframe <=1 then
                self.image:render_incamera_scaled_from_to(0,0,32,15,self.pos.x,self.pos.y + self.size.y,32,15)
            elseif self.unhidingframe == 2 then
                self.image:render_incamera_scaled_from_to(0,15,32,21,self.pos.x,self.pos.y + self.size.y - 6,32,21)
            elseif self.unhidingframe == 3 then
                self.image:render_incamera_scaled_from_to(0,36,32,27,self.pos.x,self.pos.y + self.size.y - 12,32,27)
            elseif self.unhidingframe == 4 then
                self.image:render_incamera_scaled_from_to(0,63,32,23,self.pos.x,self.pos.y,32,23)
            end
        else
            if self.frame == 1 then
                if self.dir == 1 then
                    self.image:render_incamera_scaled_from_to(0,86,23,18,self.pos.x + self.size.x,self.pos.y,self.size.x * -1,self.size.y)
                else
                    self.image:render_incamera_scaled_from_to(0,86,23,18,self.pos.x,self.pos.y,self.size.x,self.size.y)
                end
            else
                if self.dir == 1 then
                    self.image:render_incamera_scaled_from_to(0,104,23,18,self.pos.x + self.size.x,self.pos.y,self.size.x * -1,self.size.y)
                else
                    self.image:render_incamera_scaled_from_to(0,104,23,18,self.pos.x,self.pos.y,self.size.x,self.size.y)
                end
            end
            
        end
		

    else
        error("Image not loaded for KaizoDirtMonster with ID: " .. tostring(self.image_id))
    end
end


function KaizoDirtMonster:HandleProperty(prop)
    if prop.name == "dir" then
        self.dir = prop.value
    end
end

function KaizoDirtMonster:HandlePlayerCollision(player, collide)
    if collide.down == 4 then
        if player.pressing_jump then
            player.vel.y = -15
        else
            player.vel.y = -7
        end
        self.die = true
    end
end

function KaizoDirtMonster:SaveState()

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
        unhidingframe = self.unhidingframe,
        unhidingframetime = self.unhidingframetime,
        hidden = self.hidden,
    }
end

function KaizoDirtMonster:LoadState(state)
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
    
    self.unhidingframe = state.unhidingframe
    self.unhidingframetime = state.unhidingframetime
    self.hidden = state.hidden
end