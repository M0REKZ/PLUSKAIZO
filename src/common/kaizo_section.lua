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
require("common.kaizo_globals")

KaizoSection = {}

function KaizoSection:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.Layers = {}
    o.Background = nil
    o.Music = nil
    o.Size = {x = 0, y = 0}
    return o
end

function KaizoSection:update()
    -- Update logic for the section
    for _, layer in ipairs(self.Layers) do
        layer:update()
    end
end

function KaizoSection:add_layer(layer)
    self.Layers[#self.Layers + 1] = layer
end

function KaizoSection:render()

    -- Always load TEST tile
    if not KaizoContext.CurrentLevel:get_tile_image(11) then
        local image = KaizoImage:new()
        image:load_tile_image_by_id(11)
        KaizoContext.CurrentLevel:add_tile_image(image)
    end
    -- Render logic for the section
    if self.Background then
        self.Background:render_scaled_to(0,0,WindowSize.x,WindowSize.y)
    end
    for _, layer in ipairs(self.Layers) do
        layer:render_back()
        layer:render()
    end

    -- Render Limits
    local pos = {y = -1 * 32}
    for x = -1, self.Size.x, 1 do
        pos.x = x * 32
        if IsInCamera(pos.x, pos.y, 32, 32) then
            KaizoContext.CurrentLevel:get_tile_image(11):render_incamera_scaled_to(pos.x, pos.y, 32, 32)
        end
    end

    pos.y = (self.Size.y) * 32
    for x = -1, self.Size.x, 1 do
        pos.x = x * 32
        if IsInCamera(pos.x, pos.y, 32, 32) then
            KaizoContext.CurrentLevel:get_tile_image(11):render_incamera_scaled_to(pos.x, pos.y, 32, 32)
        end
    end

    pos.x = -1 * 32
    for y = 0, self.Size.y-1, 1 do
        pos.y = y * 32
        if IsInCamera(pos.x, pos.y, 32, 32) then
            KaizoContext.CurrentLevel:get_tile_image(11):render_incamera_scaled_to(pos.x, pos.y, 32, 32)
        end
    end

    pos.x = (self.Size.x) * 32
    for y = 0, self.Size.y-1, 1 do
        pos.y = y * 32
        if IsInCamera(pos.x, pos.y, 32, 32) then
            KaizoContext.CurrentLevel:get_tile_image(11):render_incamera_scaled_to(pos.x, pos.y, 32, 32)
        end
    end
    
end

function KaizoSection:SaveState()
    local temp = {}

    temp.Layers = {}
    temp.Size = self.Size

    if self.Background then
        temp.Background = self.Background:SaveState()
    end

    if self.Music then
        temp.Music = self.Music:SaveState()
    end

    for num, layer in ipairs(self.Layers) do
        temp.Layers[num] = layer:SaveState()
    end

    return temp
end

function KaizoSection:LoadState(state)

    self.Size = state.Size
    if state.Background then
        self.Background = KaizoImage:new()
        self.Background:load(state.Background.image_path)
    end

    if state.Music then
        self.Music = KaizoSound:new()
        self.Music:Load(state.Music.sound_path, state.Music.is_music)
    end

    for ind, layer in ipairs(state.Layers) do
        self.Layers[ind] = KaizoLayer:new()
        self.Layers[ind]:LoadState(layer)
    end
    
end