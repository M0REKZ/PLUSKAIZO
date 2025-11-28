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
require("common.entities.squares.kaizo_chicken")
require("common.entities.squares.kaizo_death_effect")

KaizoSign = setmetatable({}, {__index = KaizoSquare})

KaizoSign.name = "KaizoSign"
KaizoSign.__index = KaizoSign

KaizoSign.editor_properties = {}
KaizoSign.editor_properties[1] = "my_text"

function KaizoSign:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoSign)

    o.size.x = 32
    o.size.y = 32

    o.col.up = 0
    o.col.down = 0
    o.col.left = 0
    o.col.right = 0

    o.sec = nil

    o.image_id = 24 -- Default image ID for the square
    o.image = nil

    o.show_text = false
    o.my_text = "Hello, this is a Kaizo Sign!"
    o.is_on_background = true -- dont render above other entities

    o.can_load_level_properties = true

    return o
end

function KaizoSign:update()

    local player
    player = nil

    self.sec = KaizoContext.CurrentLevel:get_current_section()

    for _, layer in ipairs(self.sec.Layers) do
        for _, ent in ipairs(layer.Entities) do
            if ent == self then
                goto continue
            end

            if ent.marked_for_deletion then
                goto continue
            end

            if ent.is_player then
                if IsEntityColliding(self, ent) then
                    player = ent
                    break
                end
            end


            :: continue ::
        end
        if player then
            break
        end
    end

    if player then
        self.show_text = true
    else
        self.show_text = false
    end
    
end

function KaizoSign:render()
    KaizoSquare.render(self)

    if self.show_text then
        RenderHandler:Print2(self.my_text, ((self.pos.x - 256) - Camera.x) + self.size.x/2, (self.pos.y - 64) - Camera.y, 512, true, true)
    end
end

function KaizoSign:SaveState()
    local state = KaizoSquare.SaveState(self)
    state.my_text = self.my_text
    state.show_text = self.show_text
    return state
end

function KaizoSign:LoadState(state)
    KaizoSquare.LoadState(self,state)
    self.my_text = state.my_text
    self.show_text = state.show_text
end

function KaizoSign:HandleProperty(prop)
    if prop.name == "my_text" then
        self.my_text = prop.value
    end
end
