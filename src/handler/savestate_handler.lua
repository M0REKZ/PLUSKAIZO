-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common.kaizo_globals")
require("handler.json_handler")
require("handler.file_handler")

SaveStateHandler = {}

function SaveStateHandler:SaveState()
    KaizoFileHandler:CreateDirectory("saves")
    local str = KaizoJSONHandler:ToJSON(GameContext.CurrentLevel:SaveState())
    KaizoFileHandler:WriteFileTo("saves/save.kzstate", str)
end

function SaveStateHandler:LoadState()
    love.audio.stop()
    GameContext.CurrentLevel = nil
    local jsonstr = KaizoFileHandler:GetFileAsString("saves/save.kzstate")
    local state = KaizoJSONHandler:FromJSON(jsonstr)
    GameContext.CurrentLevel = KaizoLevel:new()
    GameContext.CurrentLevel:LoadState(state)
    local sec = GameContext.CurrentLevel:get_current_section()

    if sec.Music then
        sec.Music:Loop()
        sec.Music:Play()
    end
end

function SaveStateHandler:StateExists()
    return KaizoFileHandler:FileExists("saves/save.kzstate")
end