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

require("common.kaizo_collision")

IS_MOBILE = false

Lives = 0

Camera = {x = 0, y = 0}
WindowSize = {x = 768, y = 512}
RealWindowSize = {}

KaizoConfig = {
    "up", -- 1 up
    "down", -- 2 down
    "left", -- 3 left
    "right", -- 4 right
    "z", -- 5 jump
    "a", -- 6 spin jump
    "s", -- 7 run
    "l", -- 8 load state
    "k", -- 9 save state
    "r", -- 10 reset
}

KaizoConfigNames = {
    "up", -- 1 up
    "down", -- 2 down
    "left", -- 3 left
    "right", -- 4 right
    "jump", -- 5 jump
    "spin jump", -- 6 spin jump
    "run", -- 7 run
    "load state", -- 8 load state
    "save state", -- 9 save state
    "reset", -- 10 reset
}

LoveKeysPressed = {}
LoveLastKeyPressed = nil --for key config

function FitCameraToSize(size)
    if Camera.x < 0 then
        Camera.x = 0
    end

    if Camera.y < 0 then
        Camera.y = 0
    end

    if Camera.x + WindowSize.x > size.x * 32 then
        Camera.x = size.x * 32 - WindowSize.x
    end

    if Camera.y + WindowSize.y > size.y * 32 then
        Camera.y = size.y * 32 - WindowSize.y
    end
end