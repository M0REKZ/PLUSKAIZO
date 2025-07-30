-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

love.filesystem.setRequirePath("?.lua;?/init.lua;src/?.lua;src/?/init.lua")
require("common/kaizo_globals")
require("kaizo_context")
require("common/kaizo_level")
push = require("external.push") --required for pixel perfect scaling 

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

    love.window.setMode(WindowSize.x,WindowSize.y,{vsync = 0, resizable = true})
    

    push.setupScreen(WindowSize.x, WindowSize.y, {upscale = "normal"})
    RealWindowSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}


    love.window.maximize()
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.window.setTitle("+KAIZO")
    local icon = love.image.newImageData("data/images/icon.png")
    love.window.setIcon(icon)
    love.filesystem.setIdentity("PLUSKAIZO")
    love.audio.setVolume(0.5)

    if IS_MOBILE then
        InputHandler:InitLOVEMobileGamepad()
    end

    GameContext = KaizoContext:new()
    GameContext.CurrentLevel = KaizoLevel:new()
    GameContext:init()
end

function love.update(dt)
    --love.timer.sleep( 1/60 ) --force 60 fps
    FrameTiming = FrameTiming + dt --update timing
    if FrameTiming > 1/50 then --60 fps
        GameContext:update()

        if GameContext.Quit then
            love.event.quit()
            return
        end
        FrameRenderingFPS = FrameTiming
        FrameTiming = 0
        FrameRender = true
    end
end

function love.draw()
    if FrameRender then 
        love.graphics.setCanvas(FrameRenderer) --keep last drawn frame in memory
        love.graphics.clear()
        push.start()
        GameContext:render()
        push.finish()
        love.graphics.origin() -- push bug: push does not reset offset, so i must do it by myself

        if IS_MOBILE then
            InputHandler:DrawLOVEMobileGamepad()
        end

        if CopyrightRender > 0 then --draw copyright
            CopyrightRender = CopyrightRender -1
            love.graphics.print("(c) Copyright Benjamín Gajardo All rights reserved", 10, 10)
        end

        FrameRender = false
        love.graphics.setCanvas()
    end
    love.graphics.draw(FrameRenderer) -- always draw last frame, even if game is not updated
end

function love.keypressed(a, b)
    LoveKeysPressed[a]= true
    LoveLastKeyPressed = a
end
function love.keyreleased(a)
    LoveKeysPressed[a] = false
end