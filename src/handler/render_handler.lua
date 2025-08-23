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
    if IS_NOT_LOVE then
        -- Load the font using SDL_ttf
        local font_path = "data/images/Snowstorm.otf"
        RenderHandler.MainFont = SDL_TTF.openFont(font_path, 50)
        if RenderHandler.MainFont == 0 then
            error("Failed to load font: " .. font_path)
        end
    else
        -- Load the font using Love2D
        RenderHandler.MainFont = love.graphics.newFont("data/images/Snowstorm.otf", 15)
    end
end

function RenderHandler:Print(text,x,y)

    if IS_NOT_LOVE then
        local tempsurface = nil
        tempsurface = SDL_TTF.renderText_Solid_Wrapped(RenderHandler.MainFont, text, ffi.new("SDL_Color",{r=255, g=255, b=255}), 0)

        if tempsurface == 0 then
            error("Failed to render text as surface: " .. text)
        end

        local temptexture = nil
        temptexture = SDL.createTextureFromSurface(KaizoSDLRenderer, tempsurface)

        if temptexture == 0 then
            error("Failed to create text texture from surface: " .. text)
        end

        SDL.renderCopy(KaizoSDLRenderer, temptexture, nil, ffi.new("SDL_Rect", {x = x, y = y, w = tempsurface.w/4, h = tempsurface.h/4}))
        SDL.destroyTexture(temptexture) -- evil to create and destroy every frame, but text can be different on every frame and is not worth it to have it saved in memory
        SDL.freeSurface(tempsurface)
    else
        love.graphics.setFont(RenderHandler.MainFont)
        love.graphics.print(text,x,y)
    end
end

function RenderHandler:FreeFont()
    if IS_NOT_LOVE then
        if RenderHandler.MainFont then
            SDL_TTF.closeFont(RenderHandler.MainFont)
            RenderHandler.MainFont = nil
        end
    else
        RenderHandler.MainFont = nil
    end
end