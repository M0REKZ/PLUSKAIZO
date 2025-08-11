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
    o.cursor_path = "data/images/cursor.png"
    o.cursor = nil
    o.image = nil
    o.item = 0
    o.can_load_level_properties = true
    o.active_out_of_camera = true
    o.always_render = true

    o.option = 1
    o.option_selected = false

    o.waiting_for_key_release = false

    o.level_list_open = false
    o.level_list = nil

    return o
end

function KaizoMenuItem:update()

    self.option_selected = false

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
        
        if InputHandler.mouse_y < self.pos.y + self.size.y/3 then
            self.option = 1
            self.option_selected = true
        elseif InputHandler.mouse_y < self.pos.y + (self.size.y/3)*2 then
            self.option = 2
            self.option_selected = true
        else
            self.option = 3
            self.option_selected = true
        end

    end

    if self.item > 0 then
        if not self.waiting_for_key_release then
            if InputHandler.jump or LoveKeysPressed["return"] then
                self.waiting_for_key_release = true
                self.option_selected = true
            elseif InputHandler.up and self.option > 1 then
                self.option = self.option - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.option < 3 then
                self.option = self.option + 1
                self.waiting_for_key_release = true
            end
        end

        if self.waiting_for_key_release and not InputHandler.up and not InputHandler.down and not InputHandler.jump and not LoveKeysPressed["return"] then
            self.waiting_for_key_release = false
        end

        if self.option_selected then
            if self.option == 1 then
                self.level_list = KaizoLevelList:new(self.pos.x,self.pos.y)
                --self.ref_layer:add_entity(self.level_list)
                self.level_list.waiting_for_key_release = true
                self.level_list_open = true
                return
            elseif self.option == 2 then
                KaizoContext.GoToLevelEditor = true
                return
            else
                KaizoContext.Quit = true
                return
            end
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
        KaizoContext.CurrentLevel:add_entity_image(self.image)
    end

    if not self.cursor and self.item > 0 then
        self.cursor = KaizoImage:new()
        self.cursor:load(self.cursor_path)
        KaizoContext.CurrentLevel:add_entity_image(self.cursor)
    end

    if self.image then
        
        self.image:render_scaled_to(self.pos.x, self.pos.y, self.size.x, self.size.y)
        
    end

    if self.cursor then
        self.cursor:render_scaled_to(self.pos.x - 32, self.pos.y + (self.size.y/3) * (self.option - 1), 32, 32)
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