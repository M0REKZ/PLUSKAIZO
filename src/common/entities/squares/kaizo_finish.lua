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

KaizoFinish = setmetatable({}, {__index = KaizoSquare})

KaizoFinish.name = "KaizoFinish"
KaizoFinish.__index = KaizoFinish

function KaizoFinish:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoFinish)

    o.size.x = 20
    o.size.y = 20

    o.col.up = 4
    o.col.down = 4
    o.col.left = 4
    o.col.right = 4


    o.image_id = 18 -- Default image ID for the square
    o.image = nil
    o.seconds_for_go_back = -1

    o.active_out_of_camera = true
    o.always_render = true

    return o
end

function KaizoFinish:update()

    if self.die then
        self:destroy()
        return
    end

    if self.seconds_for_go_back > 0 then
        self.seconds_for_go_back = self.seconds_for_go_back - 1
    elseif self.seconds_for_go_back == 0 then
        KaizoContext.QueuedLevelName = KaizoContext.MainWorldLevel
        print(KaizoContext.QueuedLevelName)
        self:destroy()
        return
    end

    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    
end

function KaizoFinish:render()
    if self.seconds_for_go_back >= 0 then
        RenderHandler:Print2("Level Complete", 0,WindowSize.y/2, WindowSize.x, true, true)
    else
        KaizoSquare.render(self)
    end
end

function KaizoFinish:HandlePlayerCollision(player, collide)
    if self.seconds_for_go_back < 0 then
        self.seconds_for_go_back = 150
        self.active_out_of_camera = true
        self.always_render = true
    end
end

function KaizoFinish:SaveState()
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
        active = self.active,
        seconds_for_go_back = self.seconds_for_go_back,
        active_out_of_camera = self.active_out_of_camera,
        always_render = self.always_render,
    }
end

function KaizoFinish:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.pos = state.pos
    self.size = state.size
    self.vel = state.vel
    self.col = state.col
    self.image_id = state.image_id
    self.can_collide_square = state.can_collide_square
    self.has_collision_square = state.has_collision_square
    self.active = state.active
    self.seconds_for_go_back = state.seconds_for_go_back or self.seconds_for_go_back --dont crash when loading DEMO V9 levels
    self.active_out_of_camera = state.active_out_of_camera
    self.always_render = state.always_render
end