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

    o.background_image = nil

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

        if not self.background_image then
            self.background_image = KaizoImage:new()
            self.background_image:load("data/images/blacksquare.png")
        end

        if self.background_image then
            self.background_image:render_scaled_to(WindowSize.x/4,WindowSize.y/2,128,32)
        end

        RenderHandler:Print("Level Complete", WindowSize.x/4,WindowSize.y/2)
    else
        KaizoSquare.render(self)
    end
end

function KaizoFinish:HandlePlayerCollision(player, collide)
    if self.seconds_for_go_back < 0 then
        self.seconds_for_go_back = 150
    end
end