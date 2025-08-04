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