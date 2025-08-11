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

require("common/kaizo_section")
require("common.kaizo_globals")

KaizoLevel = {}

function KaizoLevel:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.CurrentSection = 0
    o.QueuedSection = 0
    o.Sections = {}
    o.EntityImages = {}
    o.TileImages = {}
    o.Sounds = {}
    o.Name = nil
    return o
end

function KaizoLevel:update()
    -- Update logic for the level
    if(self.CurrentSection > 0) then
        self.Sections[self.CurrentSection]:update()
    end
    if self.QueuedSection > 0 then
        self.CurrentSection = self.QueuedSection
        self.QueuedSection = 0
        if self.Sections[self.CurrentSection].Music then
            self.Sections[self.CurrentSection].Music:Loop()
            self.Sections[self.CurrentSection].Music:Play()
        end
    end
end

function KaizoLevel:render()
    -- Render logic for the level
    if(self.CurrentSection > 0) then
        self.Sections[self.CurrentSection]:render()
    end
end

function KaizoLevel:add_section(section)
    self.Sections[#self.Sections + 1] = section
end

function KaizoLevel:add_entity_image(image)
    self.EntityImages[#self.EntityImages + 1] = image
end

function KaizoLevel:get_entity_image(image_id)
    for _, image in ipairs(self.EntityImages) do
        if image.id == image_id then
            return image
        end
    end
    return nil -- Image not found
end

function KaizoLevel:add_tile_image(image)
    self.TileImages[#self.TileImages + 1] = image
end

function KaizoLevel:get_tile_image(image_id)
    for _, image in ipairs(self.TileImages) do
        if image.id == image_id then
            return image
        end
    end
    return nil -- Image not found
end

function KaizoLevel:add_sound(sound)
    self.Sounds[#self.Sounds + 1] = sound
end

function KaizoLevel:get_sound(sound_id)
    for _, sound in ipairs(self.Sounds) do
        if sound.id == sound_id then
            return sound
        end
    end
    return nil -- Sound not found
end

function KaizoLevel:set_current_section(index)
    if index > 0 and index <= #self.Sections then
        if self:get_current_section() and self:get_current_section().Music then
            self:get_current_section().Music:Stop()
        end
        self.CurrentSection = index
        if self:get_current_section() and self:get_current_section().Music then
            self:get_current_section().Music:Loop()
            self:get_current_section().Music:Play()
        end
    else
        error("Invalid section index: " .. tostring(index))
    end
end

function KaizoLevel:get_current_section()
    return self.Sections[self.CurrentSection]
end

function KaizoLevel:SaveState()
    local temp = {}

    temp.CurrentSection = self.CurrentSection
    temp.QueuedSection = self.QueuedSection
    temp.EntityImages = {}
    temp.TileImages = {}
    temp.Sections = {}
    temp.Sounds = {}
    temp.Name = self.Name

    --Globals
    temp.Camera = {x = Camera.x, y = Camera.y}
    temp.Lives = Lives --should i remove this?...
    temp.MainWorldLevel = KaizoContext.MainWorldLevel

    for num, image in ipairs(self.EntityImages) do
        temp.EntityImages[num] = image:SaveState()
    end

    for num, image in ipairs(self.TileImages) do
        temp.TileImages[num] = image:SaveState()
    end

    for num, sound in ipairs(self.Sounds) do
        temp.Sounds[num] = sound:SaveState()
    end

    for num, section in ipairs(self.Sections) do
        temp.Sections[num] = section:SaveState()
    end

    return temp
end

function KaizoLevel:LoadState(state)
    
    self.CurrentSection = state.CurrentSection
    self.QueuedSection = state.QueuedSection
    self.Name = state.Name

    --Globals

    Lives = state.Lives
    Camera = state.Camera
    KaizoContext.MainWorldLevel = state.MainWorldLevel
    
    for ind, image in pairs(state.EntityImages) do
        self.EntityImages[ind] = KaizoImage:new()
        if image.id == 0 then
            self.EntityImages[ind]:load(image.image_path)
        else
            self.EntityImages[ind]:load_entity_image_by_id(image.id)
        end
    end

    for ind, image in pairs(state.TileImages) do
        self.TileImages[ind] = KaizoImage:new()
        if image.id == 0 then
            self.TileImages[ind]:load(image.image_path)
        else
            self.TileImages[ind]:load_tile_image_by_id(image.id)
        end
    end

    for ind, sound in pairs(state.Sounds) do
        self.Sounds[ind] = KaizoSound:new()
        if sound.id == 0 then
            self.Sounds[ind]:Load(sound.image_path)
        else
            self.Sounds[ind]:LoadByID(sound.id)
        end
    end

    for ind, section in ipairs(state.Sections) do
        self.Sections[ind] = KaizoSection:new()
        self.Sections[ind]:LoadState(section)
    end
end