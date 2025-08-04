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

RenderHandler = {}

RenderHandler.MainFont = nil

function RenderHandler:InitFont()
    RenderHandler.MainFont = love.graphics.newFont("data/images/Snowstorm.otf",15)
end

function RenderHandler:Print(text,x,y)
    love.graphics.setFont(RenderHandler.MainFont)
    love.graphics.print(text,x,y)
end