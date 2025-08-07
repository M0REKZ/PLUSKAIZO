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

KaizoCameraFollow = {name = "KaizoCameraFollow"}

function KaizoCameraFollow:new(x, y)
    local o = {}
    setmetatable(o,KaizoCameraFollow)
    self.__index = KaizoCameraFollow

    o.marked_for_deletion = false
    o.active_out_of_camera = true

    o.pos = KaizoLocation:new(x, y)
    o.size = {x = 0, y = 0}
    o.image_id = 0

    return o
end

function KaizoCameraFollow:update()
    self.pos.x = self.pos.x + 1

    if self.pos.x > KaizoContext.CurrentLevel:get_current_section().Size.x * 32 then
        self.pos.x = 0
    end

    Camera.x = self.pos.x - WindowSize.x/2
    Camera.y = self.pos.y - WindowSize.y/2

    FitCameraToSize(KaizoContext.CurrentLevel:get_current_section().Size)
end

function KaizoCameraFollow:render()
end

function KaizoCameraFollow:destroy()
    self.marked_for_deletion = true
end

function KaizoCameraFollow:SaveState()
    return {
        name = self.name,
        pos = self.pos,
        size = self.size,
        marked_for_deletion = self.marked_for_deletion,
    }
end

function KaizoCameraFollow:LoadState(state)
    self.name = state.name
    self.pos = state.pos
    self.size = state.size
    self.marked_for_deletion = state.marked_for_deletion
end