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

require("common.kaizo_globals")
require("handler.input_handler")
require("handler.render_handler")
require("handler.file_handler")

KaizoConfigHandler = {
    activate = false,
    active = false,
    config_key = 1,
    background = nil,
    --NextConfig = {},
    waiting_for_key_release = false,
    waiting_for_new_key = false,
}

function KaizoConfigHandler:init()
    if IS_NOT_LOVE then
        KaizoConfig = {
        SDL.SCANCODE_UP, -- 1 up
        SDL.SCANCODE_DOWN, -- 2 down
        SDL.SCANCODE_LEFT, -- 3 left
        SDL.SCANCODE_RIGHT, -- 4 right
        SDL.SCANCODE_Z, -- 5 jump
        SDL.SCANCODE_A, -- 6 spin jump
        SDL.SCANCODE_S, -- 7 run
        SDL.SCANCODE_L, -- 8 load state
        SDL.SCANCODE_K, -- 9 save state
        SDL.SCANCODE_R, -- 10 reset
        }
    else
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
    end

    self.background = KaizoImage:new()
    self.background:load("data/images/blacksquare.png")
end

function KaizoConfigHandler:update()
    if self.activate then
        if not IS_MOBILE then
            self.active = true
            --self.NextConfig = KaizoConfig
            self.waiting_for_key_release = true
        end

        self.activate = false
    end

    if self.active then
        if self.waiting_for_new_key and not self.waiting_for_key_release and LoveLastKeyPressed then
            if not (LoveLastKeyPressed == "escape" or SDLLastKeyPressed == SDL.SCANCODE_ESCAPE) and (LoveKeysPressed[LoveLastKeyPressed] or SDLKeysPressed[SDLLastKeyPressed]) then
                KaizoConfig[self.config_key] = LoveLastKeyPressed
                self.waiting_for_new_key = false
                self.waiting_for_key_release = true
            end
        end

        if not self.waiting_for_key_release and not self.waiting_for_new_key then
            if InputHandler.jump then
                self.waiting_for_key_release = true
                self.waiting_for_new_key = true
            elseif InputHandler.up and self.config_key > 1 then
                self.config_key = self.config_key - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.config_key < 10 then
                self.config_key = self.config_key + 1
                self.waiting_for_key_release = true
            end

        end

        if self.waiting_for_key_release and not (LoveKeysPressed[LoveLastKeyPressed] or SDLKeysPressed[SDLLastKeyPressed]) and not InputHandler.up and not InputHandler.down and not InputHandler.jump and not (LoveKeysPressed["escape"] or SDLKeysPressed[SDL.SCANCODE_ESCAPE]) then
            self.waiting_for_key_release = false
        end

        if (not self.waiting_for_key_release) and (LoveKeysPressed["escape"] or SDLKeysPressed[SDL.SCANCODE_ESCAPE]) then
            self.active = false
            self.waiting_for_key_release = false
            self.config_key = 1
            InputHandler.wait_before_pause = 50
            self.activate = false
            --KaizoConfig = self.NextConfig
            self:SaveConfig()
        end
    end
end

function KaizoConfigHandler:render()
    if not self.active then
        return
    end

    self.background:render_scaled_to(0,0,256,32)
    if IS_NOT_LOVE then
        RenderHandler:Print("Handling key: " .. KaizoConfigNames[self.config_key] .. " which now is " .. tostring(ffi.string(SDL.getScancodeName(KaizoConfig[self.config_key]))), 10 , 10)
    else
        RenderHandler:Print("Handling key: " .. KaizoConfigNames[self.config_key] .. " which now is " .. KaizoConfig[self.config_key], 10 , 10)
    end
end

function KaizoConfigHandler:SaveConfig()
    KaizoFileHandler:CreateDirectory("config")
    local str = KaizoJSONHandler:ToJSON(KaizoConfig)
    KaizoFileHandler:WriteFileTo("config/kzconfig.json", str)
end

function KaizoConfigHandler:LoadConfig()
    local jsonstr = KaizoFileHandler:GetFileAsString("config/kzconfig.json")
    
    if jsonstr then
        local config = KaizoJSONHandler:FromJSON(jsonstr)
        if not config then
            return false
        end

        if IS_NOT_LOVE then
            if type(config[1]) ~= "number" then
                return false
            end
        else
            if type(config[1]) ~= "string" then
                return false
            end
        end
        KaizoConfig = config
        return true
    end

    return false
end