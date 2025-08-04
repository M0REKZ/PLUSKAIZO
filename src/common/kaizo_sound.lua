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

KaizoSound = {
    sound = nil,
    id = 0,
    sound_path = "",
    is_music = false,
}

function KaizoSound:new()
    local o = {}
    setmetatable(o, KaizoSound)
    self.__index = KaizoSound
    return o
end

function KaizoSound:Load(soundPath, is_music)
    local str
    if is_music then
        str = "stream"
    else
        str = "static"
    end

    self.sound = love.audio.newSource(soundPath, str)
    if not self.sound then
        error("failed to load sound: " .. soundPath)
    end

    self.sound_path = soundPath
    self.is_music = is_music
end

function KaizoSound:LoadByID(id, is_music)
    local soundPath
    if is_music then
        soundPath = "data/music/music_" .. tostring(id) .. ".mp3"
    else
        soundPath = "data/sounds/sound_" .. tostring(id) .. ".mp3"
    end
    self.id = id
    self:Load(soundPath, is_music)
end

function KaizoSound:Loop(b)
    local lb = b or true
    self.sound:setLooping(lb)
end

function KaizoSound:Play()
    self.sound:play()
end

function KaizoSound:Pause()
    self.sound:pause()
end

function KaizoSound:Stop()
    self.sound:stop()
end

function KaizoSound:SaveState()
    return {id = self.id, sound_path = self.sound_path, is_music = self.is_music}
end