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
require("handler.file_handler")
require("handler.render_handler")

KaizoLevelList = {name = "KaizoLevelList"}

function KaizoLevelList:new(x, y)
    local o = {}
    setmetatable(o,KaizoLevelList)
    self.__index = KaizoLevelList

    o.marked_for_deletion = false

    o.pos = KaizoLocation:new(x, y)
    o.size = {x = 256, y = 128}

    o.image_id = 0
    o.image_path = "data/images/blacksquare.png"
    o.image = nil
    o.level_selected = 1
    o.can_load_level_properties = true
    o.active_out_of_camera = true
    o.always_render = true
    o.levels = KaizoFileHandler:GetItemsInDirectory("data/levels/")

    --check valid levels

    local levelname = nil

    for index = #o.levels, 1, -1 do
        levelname = o.levels[index]

        if string.gsub(levelname, ".lvlx", "") == "init" then
            print("removing init")
            table.remove(o.levels, index)
        end

        --check for kzlvl
        if KaizoFileHandler:FileExists("data/levels/" .. levelname) and levelname:match("^.+(%..+)$") == ".kzlvl" then
            goto continue
        end

        --check for lvlx
        if KaizoFileHandler:FileExists("data/levels/" .. levelname) and levelname:match("^.+(%..+)$") == ".lvlx" then
            goto continue
        end

        --check for tmj
        if KaizoFileHandler:FileExists("data/levels/" .. levelname .. "/section_1.tmj") then
            goto continue
        end

        print("removing invalid level: " .. levelname)
        table.remove(o.levels, index)

        ::continue::
    end

    return o
end

function KaizoLevelList:update()
    if not self.waiting_for_key_release then
        if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
            self.waiting_for_key_release = true
            local name = string.gsub(self.levels[self.level_selected],".lvlx","")
            name = string.gsub(name,".kzlvl","")
            KaizoContext.QueuedLevelName = name
            self:destroy()
            return
        elseif InputHandler.up and self.level_selected > 1 then
            self.level_selected = self.level_selected - 1
            self.waiting_for_key_release = true
        elseif InputHandler.down and self.level_selected < #self.levels then
            self.level_selected = self.level_selected + 1
            self.waiting_for_key_release = true
        end
    end

    if self.waiting_for_key_release and not InputHandler.up and not InputHandler.down and not InputHandler.jump and not LoveKeysPressed["escape"] and not LoveKeysPressed["return"] and not SDLKeysPressed[SDL.SCANCODE_ESCAPE] and not SDLKeysPressed[SDL.SCANCODE_RETURN] then
        self.waiting_for_key_release = false
    end

    if (not self.waiting_for_key_release) and (LoveKeysPressed["escape"] or SDLKeysPressed[SDL.SCANCODE_ESCAPE]) then
        self:destroy()
    end
end

function KaizoLevelList:render()
    if not self.image then
        self.image = KaizoImage:new()
        self.image:load(self.image_path)
        KaizoContext.CurrentLevel:add_entity_image(self.image)
    end

    if self.image then
        self.image:render_scaled_to(self.pos.x, self.pos.y, self.size.x, self.size.y)
        RenderHandler:Print("^", self.pos.x, self.pos.y)
        local name = string.gsub(self.levels[self.level_selected],".lvlx","")
        name = string.gsub(name,".kzlvl","")
        RenderHandler:Print(name, self.pos.x, self.pos.y + 15)
        RenderHandler:Print("v", self.pos.x, self.pos.y + 30)
    end
end

function KaizoLevelList:destroy()
    self.marked_for_deletion = true
end

function KaizoLevelList:SaveState()
    return {
        name = self.name,
        pos = self.pos,
        size = self.size,
        marked_for_deletion = self.marked_for_deletion,
        image_path = self.image_path,
        level_selected = self.level_selected,
    }
end

function KaizoLevelList:LoadState(state)
    self.name = state.name
    self.pos = state.pos
    self.size = state.size
    self.marked_for_deletion = state.marked_for_deletion
    self.image_path = state.image_path
    self.level_selected = state.level_selected
end