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

require("common/kaizo_level")
require("common/entities/kaizo_square")
require("common/kaizo_section")
require("common/kaizo_layer")
require("common.kaizo_image")
require("common.entities.squares.kaizo_player")
require("common.entities.squares.kaizo_egg")
require("handler.input_handler")
require("handler.savestate_handler")
require("handler.level_handler")
require("handler.config_handler")

KaizoContext = {}

function KaizoContext:init()

    self.CurrentLevel = nil
    self.QueuedLevelName = nil
    self.Quit = false
    self.DeathLoadState = -1
    self.SavedOnCurrentLevel = false
    self.MainWorldLevel = "init" -- default "world"

    KaizoConfigHandler:init()

    if not KaizoConfigHandler:LoadConfig() then
        KaizoConfigHandler:SaveConfig()
    end

    KaizoLevelHandler:LoadLevelFromName("init")
end

function KaizoContext:update()
    InputHandler:UpdateInput()

    if not KaizoConfigHandler.active and InputHandler.pause then
        KaizoConfigHandler.activate = true
    end

    KaizoConfigHandler:update()

    if KaizoConfigHandler.active then
        return
    end

    if self.DeathLoadState > 0 then
        self.DeathLoadState = self.DeathLoadState - 1
    elseif self.DeathLoadState == 0 then
        if SaveStateHandler:StateExists() and self.SavedOnCurrentLevel then
            SaveStateHandler:LoadState()
        else --else reset level
            local name = self.CurrentLevel.Name
            KaizoLevelHandler:LoadLevelFromName(name)
        end
        self.DeathLoadState = -1
    end

    if InputHandler.savestate and self.DeathLoadState == -1 then
        SaveStateHandler:SaveState()
        self.SavedOnCurrentLevel = true
    elseif InputHandler.loadstate then
        self.DeathLoadState = -1
        if SaveStateHandler:StateExists() then
            SaveStateHandler:LoadState()
        end
    elseif InputHandler.reset then
        self.DeathLoadState = -1
        local name = self.CurrentLevel.Name
        KaizoLevelHandler:LoadLevelFromName(name)
        self.SavedOnCurrentLevel = false
    end
    if(self.CurrentLevel) then
        self.CurrentLevel:update()
    end

    if self.QueuedLevelName then
        KaizoLevelHandler:LoadLevelFromName(self.QueuedLevelName)
        KaizoContext.QueuedLevelName = nil
    end
end

function KaizoContext:render()
    if(self.CurrentLevel) then
        self.CurrentLevel:render()
    end

    KaizoConfigHandler:render()
end