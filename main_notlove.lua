package.path = package.path .. "?.lua;?/init.lua;src/?.lua;src/?/init.lua;src/external/?.lua;src/external/?/init.lua"

if jit.arch == "arm" or jit.arch == "arm64" or jit.arch == "arm64be" then
    jit.off()
end

ffi = require 'ffi'

require("common.kaizo_globals")

IS_NOT_LOVE = true

require("kaizo_context")
require("common.kaizo_level")
require("handler.file_handler")

SDL = require("sdl2")
SDL_IMAGE = require("sdl2_image.sdl2_image")
SDL_TTF = require("sdl2_ttf.sdl2_ttf")
SDL_MIXER = require("lib.sdl2_mixer")

if SDL.init(SDL.INIT_VIDEO) < 0 then
    error("Failed to initialize SDL: " .. SDL.getError())
end

if SDL_IMAGE.init(SDL_IMAGE.INIT_PNG) == 0 then
    SDL.quit()
    error("Failed to initialize SDL_image: " .. SDL_IMAGE.getError())
end

if SDL_TTF.init() ~= 0 then
    SDL_IMAGE.quit()
    SDL.quit()
    error("Failed to initialize SDL_ttf: " .. SDL_TTF.getError())
end

if SDL_MIXER.openAudio(44100, 0x8010,2,2048) < 0 then --0x8010 is AUDIO_S16SYS, defined in SDL_Audio.h
    SDL_TTF.quit()
    SDL_IMAGE.quit()
    SDL.quit()
    error("Failed to initialize SDL_mixer: " .. SDL_MIXER.getError())
end

set_current_directory(os.getenv( "PWD" ))

local running = true

KaizoSDLWindow = ffi.new("SDL_Window*")
KaizoSDLRenderer = ffi.new("SDL_Renderer*")

KaizoSDLWindow = SDL.createWindow("+KAIZO", SDL.WINDOWPOS_CENTERED, SDL.WINDOWPOS_CENTERED, WindowSize.x, WindowSize.y,
    SDL.WINDOW_RESIZABLE)

RealWindowSize = {x = WindowSize.x, y = WindowSize.y}

if not KaizoSDLWindow then
    error("Failed to create window: " .. SDL.getError())
end

KaizoSDLRenderer = SDL.createRenderer(KaizoSDLWindow, -1, SDL.RENDERER_ACCELERATED)

if not KaizoSDLRenderer then
    SDL.destroyWindow(KaizoSDLWindow)
    error("Failed to create renderer: " .. SDL.getError())
end

SDL.renderSetLogicalSize(KaizoSDLRenderer, WindowSize.x, WindowSize.y)

KaizoFileHandler:InitUserPath()
RenderHandler:InitFont()

if KaizoFileHandler:FileExists("kaizo_mod.lua") then
    dofile("kaizo_mod.lua")
end

KaizoContext:init()

SDL.startTextInput()
SDL_MIXER.volume(-1,10)
SDL_MIXER.volumeMusic(10)
SDL_MIXER.allocateChannels(SDL_MIXER_MAX_CHANNELS)

local event = ffi.new('SDL_Event')
while not KaizoContext.Quit do
    if SDL.pollEvent(event) ~= 0 then
        if event.type == SDL.QUIT then
            KaizoContext.Quit = true
        elseif event.type == SDL.WINDOWEVENT and event.window.event == SDL.WINDOWEVENT_RESIZED then  
            RealWindowSize = {x = event.window.data1, y = event.window.data2}
        elseif event.type == SDL.KEYDOWN then
            SDLKeysPressed[tonumber(event.key.keysym.scancode)] = true
            SDLLastKeyPressed = tonumber(event.key.keysym.scancode)
            if event.key.keysym.scancode == SDL.SCANCODE_BACKSPACE then
                LoveTextInput = LoveTextInput:sub(1, -2)
            end
        elseif event.type == SDL.KEYUP then
            SDLKeysPressed[tonumber(event.key.keysym.scancode)] = false
        elseif event.type == SDL.TEXTINPUT then
            LoveTextInput = LoveTextInput .. tostring(string.char(event.text.text[0]))
        end
    end

    for i = 0, SDL_MIXER_MAX_CHANNELS-1, 1 do --update sounds status
        if SDL_MIXER.Playing(i) == 0 and SDL_MIXER_CHANNEL_SOUNDS[i] then
            SDL_MIXER_CHANNEL_SOUNDS[i].sdl_channel = -1
            SDL_MIXER_CHANNEL_SOUNDS[i] = nil
        end
    end

    KaizoContext:update()

    SDL.renderClear(KaizoSDLRenderer)
    KaizoContext:render()
    SDL.renderPresent(KaizoSDLRenderer)

    SDL.delay(1000/50)
end

RenderHandler:FreeFont()

SDL.stopTextInput()

SDL.destroyRenderer(KaizoSDLRenderer)
SDL.destroyWindow(KaizoSDLWindow)
SDL_MIXER.quit()
SDL_TTF.quit()
SDL_IMAGE.quit()
SDL.quit()
