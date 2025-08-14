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

KaizoDoor = setmetatable({}, {__index = KaizoSquare})

KaizoDoor.name = "KaizoDoor"
KaizoDoor.__index = KaizoDoor

KaizoDoor.editor_properties = {}
KaizoDoor.editor_properties[1] = "to_section"
KaizoDoor.editor_properties[2] = "to_door_name"
KaizoDoor.editor_properties[3] = "my_door_name"

function KaizoDoor:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoDoor)

    o.size.x = 32
    o.size.y = 64

    o.col.up = 4
    o.col.down = 4
    o.col.left = 4
    o.col.right = 4


    o.image_id = 19 -- Default image ID for the square
    o.image = nil
    o.is_on_background = true -- dont render above other entities

    o.entering_player = nil
    o.frames_to_teleport = 50
    o.can_load_level_properties = true

    o.to_section = 1
    o.to_door_name = ""
    o.my_door_name = ""

    return o
end

function KaizoDoor:update()

    if self.entering_player and self.entering_player.ref_layer then
        self.entering_player = nil --dont handle player multiple times
    end

    --if self.entering_player then
    --    self.entering_player:update()
    --end

    if self.die then
        if self.entering_player then
            self.ref_layer:add_entity(self.entering_player)
            self.entering_player = nil
        end
        self:destroy()
        return
    end
    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y


    if self.entering_player then
        if self.frames_to_teleport > 0 then
            self.frames_to_teleport = self.frames_to_teleport - 1
        else
            -- teleport player

            if self.to_section <=0 or self.to_section > #KaizoContext.CurrentLevel.Sections then
                error("LEVEL ERROR: Door \'to_section\' is out of range")
            end

            local sec = KaizoContext.CurrentLevel.Sections[self.to_section]

            local otherdoor = nil
            for index, layer in ipairs(sec.Layers) do
                for index, ent in ipairs(layer.Entities) do
                    if ent.my_door_name == self.to_door_name then
                        self.entering_player.pos.y = ent.pos.y + ent.size.y - self.entering_player.size.y
                        self.entering_player.pos.x = ent.pos.x + ent.size.x/2 - self.entering_player.size.x/2
                        layer:add_entity(self.entering_player)
                        self.entering_player = nil
                        KaizoContext.CurrentLevel:set_current_section(self.to_section)
                        break
                    end
                end

                if not self.entering_player then
                    break
                end
            end

            if self.entering_player then
                error("LEVEL ERROR: Door not found")
            end
        end
    end
    
end

function KaizoDoor:render()
    KaizoSquare.render(self)
    if self.entering_player then
        self.entering_player:render()
    end
    
end

function KaizoDoor:HandlePlayerCollision(player, collide)
    
    if not self.entering_player and player.pressing_up and not self.marked_for_deletion and player.ref_layer then
        self.entering_player = player
        self.frames_to_teleport = 50
        self.entering_player.ref_layer:remove_entity(self.entering_player)
    end
    
end

function KaizoDoor:HandleProperty(prop)
    if prop.name == "to_section" then
        self.to_section = prop.value
    elseif prop.name == "to_door_name" then
        self.to_door_name = prop.value
    elseif prop.name == "my_door_name" then
        self.my_door_name = prop.value
    end
end

function KaizoDoor:SaveState()
    local state = KaizoSquare.SaveState(self)

    if self.entering_player then
        state.entering_player = self.entering_player:SaveState()
    else
        state.entering_player = nil
    end

    state.to_section = self.to_section
    state.to_door_name = self.to_door_name
    state.my_door_name = self.my_door_name

    return state
end

function KaizoDoor:LoadState(state)

    KaizoSquare.LoadState(self, state)

    self.to_section = state.to_section
    self.to_door_name = state.to_door_name
    self.my_door_name = state.my_door_name

    if state.entering_player then
        self.entering_player = KaizoPlayer:new(self.pos.x,self.pos.y)
        self.entering_player:LoadState(state.entering_player)
    else
        self.entering_player = nil
    end
end