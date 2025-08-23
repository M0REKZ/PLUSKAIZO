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

KaizoMushroom = setmetatable({}, {__index = KaizoSquare})

KaizoMushroom.name = "KaizoMushroom"
KaizoMushroom.__index = KaizoMushroom

function KaizoMushroom:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoMushroom)

    o.size.x = 20
    o.size.y = 20

    o.col.up = 4
    o.col.down = 4
    o.col.left = 4
    o.col.right = 4


    o.image_id = 7 -- Default image ID for the square
    o.image = nil

    return o
end

function KaizoMushroom:update()

    if self.die then
        self:destroy()
        return
    end
    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    
end

function KaizoMushroom:HandlePlayerCollision(player, collide)
    
    player.die = true
    self.die = true
end