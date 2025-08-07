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

KaizoLogo = {name = "KaizoLogo"}

function KaizoLogo:new(x, y)
    local o = {}
    setmetatable(o,KaizoLogo)
    self.__index = KaizoLogo

    o.marked_for_deletion = false

    --o.pos = KaizoLocation:new(x, y)

    o.image_id = 0
    o.image_path = "data/images/kzlogo.png"
    o.image = nil
    o.framestowait = 60
    o.nextsection = 1
    o.active_out_of_camera = true
    o.always_render = true

    return o
end

function KaizoLogo:update()
    if not self.image then
        self.image = KaizoImage:new()
        self.image:load(self.image_path)
        KaizoContext.CurrentLevel:add_entity_image(self.image)
    end

    self.framestowait = self.framestowait - 1

    if self.framestowait <= 0 then
        self:destroy()
        KaizoContext.CurrentLevel.QueuedSection = self.nextsection
    end
end

function KaizoLogo:render()
    if self.image then
        self.image:render_scaled_to(0 + WindowSize.x/5, 0 + WindowSize.y/5, WindowSize.x - (WindowSize.x/5)*2, WindowSize.y - (WindowSize.y/5)*2)
    end
end

function KaizoLogo:destroy()
    self.marked_for_deletion = true
end

function KaizoLogo:SaveState()
    return {
        name = self.name,
        marked_for_deletion = self.marked_for_deletion,
        image_path = self.image_path,
        framestowait = self.framestowait,
        nextsection = self.nextsection,
    }
end

function KaizoLogo:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.image_path = state.image_path
    self.framestowait = state.framestowait
    self.nextsection = state.nextsection
end