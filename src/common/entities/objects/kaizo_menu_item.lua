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
require("common.entities.objects.kaizo_level_list")

KaizoMenuItem = {name = "KaizoMenuItem"}

function KaizoMenuItem:new(x, y)
    local o = {}
    setmetatable(o,KaizoMenuItem)
    self.__index = KaizoMenuItem

    o.marked_for_deletion = false

    o.pos = KaizoLocation:new(x, y)
    o.size = {x = 256, y = 128}

    o.image_id = 0
    o.image_path = "data/images/pluskzlogo.png"
    o.image = nil
    o.item = 0
    o.can_load_level_properties = true

    o.level_list_open = false
    o.level_list = nil

    return o
end

function KaizoMenuItem:update()

    if self.level_list then
        self.level_list:update()
        if self.level_list.marked_for_deletion then
            self.level_list = nil
        end
        return
    else
        self.level_list_open = false
    end

    if self.item > 0 and InputHandler.mouse_click and InputHandler.mouse_x > self.pos.x and InputHandler.mouse_x < self.pos.x + self.size.x and InputHandler.mouse_y > self.pos.y and InputHandler.mouse_y < self.pos.y + self.size.y then
        
        if InputHandler.mouse_y < self.pos.y + self.size.y/2 then
            self.level_list = KaizoLevelList:new(self.pos.x,self.pos.y)
            --self.ref_layer:add_entity(self.level_list)
            self.level_list_open = true
            return
        else
            GameContext.Quit = true
            return
        end

    end
end

function KaizoMenuItem:render()

    if self.level_list then
        self.level_list:render()
        return
    end
    if not self.image then
        self.image = KaizoImage:new()
        self.image:load(self.image_path)
        GameContext.CurrentLevel:add_entity_image(self.image)
    end

    if self.image then
        if self.item == 0 then
            self.image:render_scaled_to(self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.item == 1 or self.item == 2 then --evil way to merge both menu options
            self.image:render_scaled_from_to(0,0,188,83,self.pos.x, self.pos.y, self.size.x, self.size.y)
        end
    end
end

function KaizoMenuItem:destroy()
    self.marked_for_deletion = true
end

function KaizoMenuItem:SaveState()
    local temp = {
        name = self.name,
        pos = self.pos,
        size = self.size,
        marked_for_deletion = self.marked_for_deletion,
        image_path = self.image_path,
        item = self.item,
        level_list_open = self.level_list_open,
    }

    if temp.level_list_open then
        temp.level_list_state = self.level_list:SaveState()
    end

    return temp
end

function KaizoMenuItem:LoadState(state)
    self.name = state.name
    self.pos = state.pos
    self.size = state.size
    self.marked_for_deletion = state.marked_for_deletion
    self.image_path = state.image_path
    self.item = state.item
    self.level_list_open = state.level_list_open
    self.level_list_state = state.level_list_state

    if self.level_list_open and self.level_list_state then
        self.level_list = KaizoLevelList:new(self.pos.x,self.pos.y)
        self.level_list:LoadState(self.level_list_state)
        --self.ref_layer:add_entity(self.level_list)
    end
end

function KaizoMenuItem:HandleProperty(prop)
    if prop.name == "item" then
        self.item = prop.value
    elseif prop.name == "sizex" then
        self.size.x = prop.value
    elseif prop.name == "sizey" then
        self.size.y = prop.value
    end

    if self.item > 0 then
        self.image_path = "data/images/ui_menu.png"
    end
end