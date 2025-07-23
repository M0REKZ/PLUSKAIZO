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

KaizoContext = {}

function KaizoContext:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.CurrentLevel = nil
    o.QueuedLevelName = nil
    o.Quit = false
    return o
end

function KaizoContext:init()
    KaizoLevelHandler:LoadLevelFromName("init")
end

function KaizoContext:update()
    InputHandler:UpdateInput()

    if InputHandler.savestate then
        SaveStateHandler:SaveState()
    elseif InputHandler.loadstate then
        SaveStateHandler:LoadState()
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
end