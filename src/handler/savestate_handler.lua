--[[
    PLUSKAIZO
    Copyright (c) Benjamín Gajardo All rights reserved

    You are not allowed to use or read this code without my explicit permission
--]]

require("common.kaizo_globals")
require("handler.json_handler")
require("handler.file_handler")
require("handler.input_handler")

SaveStateHandler = {}

function SaveStateHandler:SaveState()
    if InputHandler.MustReleaseSave then
        return
    end

    KaizoFileHandler:CreateDirectory("saves")
    SaveStateHandler:SaveStateToFolder("saves","save","kzstate")
end

function SaveStateHandler:SaveStateToFolder(path,name,extension)
    if KaizoFileHandler:FileExists(path) then
        local str = KaizoJSONHandler:ToJSON(KaizoContext.CurrentLevel:SaveState())
        KaizoFileHandler:WriteFileTo(path.."/"..name.."."..extension, str)
    end
end

function SaveStateHandler:LoadState()
    if InputHandler.MustReleaseLoad then
        return
    end

    SaveStateHandler:LoadStateFrom("saves/save.kzstate")
end

function SaveStateHandler:LoadStateFrom(statepath)
    if IS_NOT_LOVE then
        SDL_MIXER.HaltMusic()
        SDL_MIXER.HaltChannel(-1)
    else
        love.audio.stop()
    end
    KaizoContext.CurrentLevel = nil
    local jsonstr = KaizoFileHandler:GetFileAsString(statepath)
    if not jsonstr then
        error("File not found: "..statepath)
    end
    local state = KaizoJSONHandler:FromJSON(jsonstr)
    KaizoContext.CurrentLevel = KaizoLevel:new()
    KaizoContext.CurrentLevel:LoadState(state)
    local sec = KaizoContext.CurrentLevel:get_current_section()

    if sec.Music then
        sec.Music:Loop()
        sec.Music:Play()
    end
end

function SaveStateHandler:StateExists()
    return KaizoFileHandler:FileExists("saves/save.kzstate")
end