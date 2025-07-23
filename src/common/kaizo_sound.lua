-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

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