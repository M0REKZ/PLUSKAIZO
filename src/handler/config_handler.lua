require("common.kaizo_globals")
require("handler.input_handler")
require("handler.render_handler")
require("handler.file_handler")

KaizoConfigHandler = {
    activate = false,
    active = false,
    config_key = 1,
    background = nil,
    --NextConfig = {},
    waiting_for_key_release = false,
    waiting_for_new_key = false,
}

function KaizoConfigHandler:init()
    self.background = KaizoImage:new()
    self.background:load("data/images/blacksquare.png")
end

function KaizoConfigHandler:update()
    if self.activate then
        if not IS_MOBILE then
            self.active = true
            --self.NextConfig = KaizoConfig
            self.waiting_for_key_release = true
        end

        self.activate = false
    end

    if self.active then
        if self.waiting_for_new_key and not self.waiting_for_key_release and LoveLastKeyPressed then
            if not (LoveLastKeyPressed == "escape") and LoveKeysPressed[LoveLastKeyPressed] then
                KaizoConfig[self.config_key] = LoveLastKeyPressed
                self.waiting_for_new_key = false
                self.waiting_for_key_release = true
            end
        end

        if not self.waiting_for_key_release and not self.waiting_for_new_key then
            if InputHandler.jump then
                self.waiting_for_key_release = true
                self.waiting_for_new_key = true
            elseif InputHandler.up and self.config_key > 1 then
                self.config_key = self.config_key - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.config_key < 10 then
                self.config_key = self.config_key + 1
                self.waiting_for_key_release = true
            end

        end

        if self.waiting_for_key_release and not LoveKeysPressed[LoveLastKeyPressed] and not InputHandler.up and not InputHandler.down and not InputHandler.jump and not LoveKeysPressed["escape"] then
            self.waiting_for_key_release = false
        end

        if (not self.waiting_for_key_release) and LoveKeysPressed["escape"] then
            self.active = false
            self.waiting_for_key_release = false
            self.config_key = 1
            InputHandler.wait_before_pause = 50
            self.activate = false
            --KaizoConfig = self.NextConfig
            self:SaveConfig()
        end
    end
end

function KaizoConfigHandler:render()
    if not self.active then
        return
    end

    self.background:render_scaled_to(0,0,256,256)
    RenderHandler:Print("Handling key: " .. KaizoConfigNames[self.config_key] .. " which now is " .. KaizoConfig[self.config_key], 10 , 10)
end

function KaizoConfigHandler:SaveConfig()
    KaizoFileHandler:CreateDirectory("config")
    local str = KaizoJSONHandler:ToJSON(KaizoConfig)
    KaizoFileHandler:WriteFileTo("config/kzconfig.json", str)
end

function KaizoConfigHandler:LoadConfig()
    local jsonstr = KaizoFileHandler:GetFileAsString("config/kzconfig.json")
    
    if jsonstr then
        local configfile = nil
        KaizoConfig = KaizoJSONHandler:FromJSON(jsonstr)
        return true
    end

    return false
end