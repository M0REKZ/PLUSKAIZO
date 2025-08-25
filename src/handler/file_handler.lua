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

local nativefs = nil
if not IS_NOT_LOVE then
    nativefs = require("external.nativefs")
end

KaizoFileHandler = {}

KaizoFileHandler.PLUSKAIZO_USER_PATH = nil

KaizoFileHandler.PLUSKAIZO_LOVE_PATH = nil
KaizoFileHandler.PLUSKAIZO_CUSTOM_PATH = nil
KaizoFileHandler.PLUSKAIZO_PLATFORM_PATH = ""

function KaizoFileHandler:InitUserPath()

    if IS_NOT_LOVE then
        
        if ffi.os == "Windows" then
            self.PLUSKAIZO_CUSTOM_PATH = os.getenv( "userprofile" ).."/PLUSKAIZO/"
            self.PLUSKAIZO_LOVE_PATH = io.popen("cd"):read().."/"
        else
            self.PLUSKAIZO_CUSTOM_PATH = os.getenv( "HOME" ).."/PLUSKAIZO/"
            self.PLUSKAIZO_LOVE_PATH = os.getenv( "PWD" ).."/"
        end
        return
    end

    local platform = love.system.getOS()

    if platform == "Linux" then
        self.PLUSKAIZO_PLATFORM_PATH = ".local/share/"
    end

    self.PLUSKAIZO_LOVE_PATH = love.filesystem.getSaveDirectory()
    self.PLUSKAIZO_CUSTOM_PATH = (love.filesystem.getUserDirectory()..self.PLUSKAIZO_PLATFORM_PATH.."PLUSKAIZO")

    if platform == "Windows" or platform == "OS X" or platform == "Linux" then -- this does not work in mobile
        nativefs.setWorkingDirectory(love.filesystem.getUserDirectory()..self.PLUSKAIZO_PLATFORM_PATH)
        local success = nativefs.createDirectory("PLUSKAIZO")
        if not success then
            error("could not create PLUSKAIZO directory")
        end
        nativefs.setWorkingDirectory(self.PLUSKAIZO_CUSTOM_PATH) -- the same path but inside the PLUSKAIZO directory
        KaizoFileHandler.PLUSKAIZO_USER_PATH = nativefs.getWorkingDirectory()
        if KaizoFileHandler.PLUSKAIZO_USER_PATH == (self.PLUSKAIZO_CUSTOM_PATH) then --we must make sure we are on the correct directory
            nativefs.mount(KaizoFileHandler.PLUSKAIZO_USER_PATH)
        else
            error("error on set working directory")
        end
    else
        KaizoFileHandler.PLUSKAIZO_USER_PATH = self.PLUSKAIZO_LOVE_PATH
    end
end

-- here nativefs is not used, since it does not search files the way i need
-- since nativefs mounted PLUSKAIZO_USER_PATH, love will still read files
-- from the custom PLUSKAIZO directory
function KaizoFileHandler:GetFileAsString(filepath)

    if IS_NOT_LOVE then
        local f = io.open(self.PLUSKAIZO_CUSTOM_PATH..filepath, "r")
        if not f then
            print("Failed to open file: " .. self.PLUSKAIZO_CUSTOM_PATH..filepath)
            f = io.open(self.PLUSKAIZO_LOVE_PATH..filepath, "r")
            if not f then
                print("Failed to open file: " .. self.PLUSKAIZO_LOVE_PATH..filepath)
                return nil
            end
        end
        local content = f:read("*all")
        f:close()
        return content
    end

    if KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_LOVE_PATH or KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_CUSTOM_PATH then
        return love.filesystem.read(filepath)
    else
        error("PLUSKAIZO_USER_PATH has wrong path")
    end
end

function KaizoFileHandler:GetFileLine(filepath)

    if IS_NOT_LOVE then
        local f = io.open(self.PLUSKAIZO_CUSTOM_PATH..filepath, "r")
        if not f then
            print("Failed to open file: " .. self.PLUSKAIZO_CUSTOM_PATH..filepath)
            f = io.open(self.PLUSKAIZO_LOVE_PATH..filepath, "r")
            if not f then
                print("Failed to open file: " .. self.PLUSKAIZO_LOVE_PATH..filepath)
                return nil
            end
        end
        local lines = {}
        for line in f:lines() do
            lines[#lines + 1] = line
        end
        f:close()
        return lines
    end

    if KaizoFileHandler.PLUSKAIZO_USER_PATH == KaizoFileHandler.PLUSKAIZO_LOVE_PATH then
        return love.filesystem.lines(filepath)
    elseif KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_CUSTOM_PATH then
        return nativefs.lines(filepath)
    else
        error("PLUSKAIZO_USER_PATH has wrong path")
    end
end

function KaizoFileHandler:WriteFileTo(filepath, content)

    if IS_NOT_LOVE then
        local f = io.open(self.PLUSKAIZO_CUSTOM_PATH..filepath, "w")
        if not f then
            error("Failed to open file for writing: " .. self.PLUSKAIZO_CUSTOM_PATH..filepath)
            return nil
        end
        f:write(content)
        f:close()
        return f ~= nil
    end
    if KaizoFileHandler.PLUSKAIZO_USER_PATH == KaizoFileHandler.PLUSKAIZO_LOVE_PATH then
        return love.filesystem.write(filepath, content)
    elseif KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_CUSTOM_PATH then
        return nativefs.write(filepath, content)
    else
        error("PLUSKAIZO_USER_PATH has wrong path")
    end
end

function KaizoFileHandler:FileExists(filepath)

    if IS_NOT_LOVE then
        local f = io.open(self.PLUSKAIZO_CUSTOM_PATH..filepath, "r")
        if not f then
            f = io.open(self.PLUSKAIZO_LOVE_PATH..filepath, "r")
        end
        if f then f:close() end
        return f ~= nil
    end

    if KaizoFileHandler.PLUSKAIZO_USER_PATH == KaizoFileHandler.PLUSKAIZO_LOVE_PATH or KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_CUSTOM_PATH then
        return love.filesystem.getInfo(filepath)
    else
        error("PLUSKAIZO_USER_PATH has wrong path")
    end
end

function KaizoFileHandler:CreateDirectory(filepath)

    if IS_NOT_LOVE then
        return cpp_kaizo_create_directory(self.PLUSKAIZO_CUSTOM_PATH..filepath)
    end
    
    if KaizoFileHandler.PLUSKAIZO_USER_PATH == KaizoFileHandler.PLUSKAIZO_LOVE_PATH then
        return love.filesystem.createDirectory(filepath)
    elseif KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_CUSTOM_PATH then
        return nativefs.createDirectory(filepath)
    else
        error("PLUSKAIZO_USER_PATH has wrong path")
    end
end

function KaizoFileHandler:GetItemsInDirectory(dirpath)

    if IS_NOT_LOVE then
        local temp = cpp_kaizo_list_items_in_path(dirpath)
        local temp2 = cpp_kaizo_list_items_in_path(self.PLUSKAIZO_CUSTOM_PATH..dirpath)
        for i=1,#temp2 do
            temp[#temp+1] = temp2[i]
        end
        return temp
    end
    if KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_LOVE_PATH or KaizoFileHandler.PLUSKAIZO_USER_PATH == self.PLUSKAIZO_CUSTOM_PATH then
        return love.filesystem.getDirectoryItems(dirpath)
    else
        error("PLUSKAIZO_USER_PATH has wrong path")
    end
end