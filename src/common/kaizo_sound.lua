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
    sdl_channel = -1,
    sdl_paused = false,
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

    if IS_NOT_LOVE then
        self.sound = nil
        if is_music then
            self.sound = SDL_MIXER.loadMUS(soundPath)
            if self.sound == 0 then
                error("failed to load music: " .. soundPath)
            end
            self.sound = ffi.gc(self.sound, SDL_MIXER.freeMusic) -- ensure music is freed
        else
            self.sound = SDL_MIXER.loadWAV(soundPath)
            if self.sound == 0 then
                error("failed to load sound: " .. soundPath)
            end
            self.sound = ffi.gc(self.sound, SDL_MIXER.freeChunk) -- ensure chunk is freed
        end
    else
        self.sound = love.audio.newSource(soundPath, str)
        if not self.sound then
            error("failed to load sound: " .. soundPath)
        end
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
    if not IS_NOT_LOVE then
        self.sound:setLooping(lb)
    end
end

function KaizoSound:Play()
    if IS_NOT_LOVE then
        if self.is_music then
            if SDL_MIXER.PlayingMusic() == 0 then
            
                SDL_MIXER.PlayMusic(self.sound, -1)
            else
                -- If the music is paused
                if SDL_MIXER.PausedMusic() == 1 then
                    -- Resume the music
                    SDL_MIXER.ResumeMusic()
                end
                
            end
        else
        
            if self.is_music or (self.sdl_channel ~= -1 and SDL_MIXER_CHANNEL_SOUNDS[self.sdl_channel] == self) then
                if self.sdl_paused then
                    if self.is_music then
                        SDL_MIXER.ResumeMusic()
                    else
                        SDL_MIXER.Resume(self.sdl_channel)
                    end
                    self.sdl_paused = false
                    return --already playing
                else
                    self:Stop()
                end
            end
            --find free sdl channel and save it
            for i=0, SDL_MIXER_MAX_CHANNELS-1, 1 do
                if SDL_MIXER.Playing(i) == 0 then
                    self.sdl_channel = i
                    SDL_MIXER_CHANNEL_SOUNDS[i] = self
                    SDL_MIXER.PlayChannel( self.sdl_channel, self.sound, 0 )
                    break
                end
            end
        end
    else
        self.sound:play()
    end
end

function KaizoSound:Pause()
    if IS_NOT_LOVE then
        if self.is_music then
            SDL_MIXER.PauseMusic()
        elseif self.sdl_channel ~= -1 and SDL_MIXER_CHANNEL_SOUNDS[self.sdl_channel] == self then
            SDL_MIXER.Pause(self.sdl_channel)
            self.sdl_paused = true
        end
    else
        self.sound:pause()
    end
end

function KaizoSound:Stop()
    if IS_NOT_LOVE then
        if self.is_music then
            SDL_MIXER.HaltMusic()
        elseif self.sdl_channel ~= -1 and SDL_MIXER_CHANNEL_SOUNDS[i] == self then
            SDL_MIXER.HaltChannel(self.sdl_channel)
            self.sdl_paused = false
        end
    else
        self.sound:stop()
    end
end

function KaizoSound:SaveState()
    return {id = self.id, sound_path = self.sound_path, is_music = self.is_music}
end