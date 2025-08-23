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

love.filesystem.setRequirePath("?.lua;?/init.lua;src/?.lua;src/?/init.lua;src/external/?.lua;src/external/?/init.lua")
require("common.kaizo_globals")
require("kaizo_context")
require("common.kaizo_level")
require("handler.file_handler")
require("handler.render_handler")
push = require("external.push") --required for pixel perfect scaling
local utf8 = require("utf8")

local FrameTiming = 0
local FrameRender = false
local FrameRenderer = love.graphics.newCanvas() --to keep drawing even if there are not changes in the game
local CopyrightRender = 50

function love.resize(width, height)
    FrameRenderer = nil -- reset canvas
    FrameRenderer = love.graphics.newCanvas(width,height) --to keep drawing even if there are not changes in the game
	push.resize(width, height)
    RealWindowSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}

    InputHandler:RecalculateLOVEMobileButtonPostions()
end

function love.load()

    local mobile = love.system.getOS()

    if mobile == "Android" or mobile == "iOS" then
        IS_MOBILE = true
    end

    KaizoFileHandler:InitUserPath()

    love.window.setMode(WindowSize.x,WindowSize.y,{vsync = 0, resizable = true})
    

    push.setupScreen(WindowSize.x, WindowSize.y, {upscale = "normal"})
    RealWindowSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}


    love.window.maximize()
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.window.setTitle("+KAIZO")
    local icon = love.image.newImageData("data/images/icon.png")
    love.window.setIcon(icon)
    love.filesystem.setIdentity("PLUSKAIZO")
    love.audio.setVolume(0.1)

    RenderHandler:InitFont()

    if IS_MOBILE then
        InputHandler:InitLOVEMobileGamepad()
    end

    if KaizoFileHandler:FileExists("kaizo_mod.lua") then
        dofile("kaizo_mod.lua")
    end

    KaizoContext:init()
end

function love.update(dt)

    FrameTiming = FrameTiming + dt --update timing
    if FrameTiming > 1/50 then -- update each 1/50 of a second
        KaizoContext:update()

        if KaizoContext.Quit then
            love.event.quit()
            return
        end
        FrameRenderingFPS = FrameTiming
        FrameTiming = 0
        FrameRender = true

        -- we have 1/50 - 1/1000 of a second to sleep, so we sleep a while,
        -- otherwise löve uses 50% of CPU, since vsync is disabled
        love.timer.sleep(1/60)
    end
end

function love.draw()
    if FrameRender then 
        love.graphics.setCanvas(FrameRenderer) --keep last drawn frame in memory
        love.graphics.clear()
        push.start()
        KaizoContext:render()
        push.finish()
        love.graphics.origin() -- push bug: push does not reset offset, so i must do it by myself

        if IS_MOBILE then
            InputHandler:DrawLOVEMobileGamepad()
        end

        if CopyrightRender > 0 then --draw copyright
            CopyrightRender = CopyrightRender -1
            love.graphics.print("(c) Copyright Benjamín Gajardo All rights reserved\nVisit m0rekz.github.io for other projects", 10, 10)
        end

        FrameRender = false
        love.graphics.setCanvas()
    end
    love.graphics.draw(FrameRenderer) -- always draw last frame, even if game is not updated
end

function love.keypressed(a, b)
    LoveKeysPressed[a]= true
    LoveLastKeyPressed = a

    if a == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(LoveTextInput, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            LoveTextInput = string.sub(LoveTextInput, 1, byteoffset - 1)
        end
    end
end
function love.keyreleased(a)
    LoveKeysPressed[a] = false
end
function love.textinput(text)
    LoveTextInput = LoveTextInput .. text
end
