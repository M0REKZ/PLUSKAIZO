-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

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

function KaizoContext:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.CurrentLevel = nil
    o.QueuedLevelName = nil
    o.Quit = false
    o.DeathLoadState = -1
    return o
end

function KaizoContext:init()

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
        if SaveStateHandler:StateExists() then
            SaveStateHandler:LoadState()
        else --else reset level
            local name = self.CurrentLevel.Name
            KaizoLevelHandler:LoadLevelFromName(name)
        end
        self.DeathLoadState = -1
    end

    if InputHandler.savestate and self.DeathLoadState == -1 then
        SaveStateHandler:SaveState()
    elseif InputHandler.loadstate then
        self.DeathLoadState = -1
        if SaveStateHandler:StateExists() then
            SaveStateHandler:LoadState()
        end
    elseif InputHandler.reset then
        local name = self.CurrentLevel.Name
        KaizoLevelHandler:LoadLevelFromName(name)
    end
    if(self.CurrentLevel) then
        self.CurrentLevel:update()
    end

    if self.QueuedLevelName then
        KaizoLevelHandler:LoadLevelFromName(self.QueuedLevelName)
        self.QueuedLevelName = nil
    end
end

function KaizoContext:render()
    if(self.CurrentLevel) then
        self.CurrentLevel:render()
    end

    KaizoConfigHandler:render()
end