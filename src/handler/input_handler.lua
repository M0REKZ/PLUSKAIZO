-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common.kaizo_globals")

InputHandler = {
    left = false,
    right = false,
    down = false,
    up = false,
    jump = false,
    spinjump = false,
    run = false,
    loadstate = false,
    savestate = false,
    reset = false,
    mouse_x = -1,
    mouse_y = -1,
    mouse_click = false,
    pause = false,
    wait_before_pause = 0,
}

function InputHandler:UpdateInput()

    if not IS_MOBILE then

        if self.wait_before_pause > 0 then
            self.wait_before_pause = self.wait_before_pause -1
            self.pause = false
        elseif LoveKeysPressed["escape"] then
            self.pause = true
        else
            self.pause = false
        end

        if love.keyboard.isDown(KaizoConfig[3]) then
            self.left = true
        else
            self.left = false
        end

        if love.keyboard.isDown(KaizoConfig[4]) then
            self.right = true
        else
            self.right = false
        end

        if love.keyboard.isDown(KaizoConfig[2]) then
            self.down = true
        else
            self.down = false
        end

        if love.keyboard.isDown(KaizoConfig[1]) then
            self.up = true
        else
            self.up = false
        end

        if love.keyboard.isDown(KaizoConfig[5]) then
            self.jump = true
        else
            self.jump = false
        end

        if love.keyboard.isDown(KaizoConfig[6]) then
            self.spinjump = true
        else
            self.spinjump = false
        end

        if love.keyboard.isDown(KaizoConfig[7]) then
            self.run = true
        else
            self.run = false
        end

        if love.keyboard.isDown(KaizoConfig[8]) then
            self.loadstate = true
        else
            self.loadstate = false
        end

        if love.keyboard.isDown(KaizoConfig[9]) then
            self.savestate = true
        else
            self.savestate = false
        end

        if love.keyboard.isDown(KaizoConfig[10]) then
            self.reset = true
        else
            self.reset = false
        end

        if love.mouse.isDown(1) then
            self.mouse_click = true
        else
            self.mouse_click = false
        end

        local x, y = push.toGame(love.mouse.getX(),love.mouse.getY())

        if x and y then
            self.mouse_x, self.mouse_y = x, y
        end
    else
        local x, y

        local handledjoy = false
        local handledspinjump = false
        local handledjump = false
        local handledrun = false
        local handledreset = false
        local handledsavestate = false
        local handledloadstate = false

        self.down = false
        self.up = false
        self.left = false
        self.right = false
        self.jump = false
        self.run = false
        self.reset = false
        self.mouse_click = false
        self.spinjump = false
        self.loadstate = false
        self.savestate = false

        for _, id in ipairs(love.touch.getTouches()) do
            x, y = love.touch.getPosition(id)

            if not handledjoy and y > self.joystick.pos.y and y < self.joystick.pos.y + self.joystick.size.y and x > self.joystick.pos.x and x < self.joystick.pos.x + self.joystick.size.x then
                local offsety = y - self.joystick.pos.y
                local offsetx = x - self.joystick.pos.x

                if offsetx < self.joystick.size.x/3 then
                    self.left = true
                end

                if offsetx > (self.joystick.size.x/3)*2 then
                    self.right = true
                end

                if offsety < self.joystick.size.y/3 then
                    self.up = true
                end

                if offsety > (self.joystick.size.y/3)*2 then
                    self.down = true 
                end

                handledjoy = true
            elseif not handledjump and y > self.jump_button.pos.y and y < self.jump_button.pos.y + self.jump_button.size.y and x > self.jump_button.pos.x and x < self.jump_button.pos.x + self.jump_button.size.x then
                self.jump = true
                handledjump = true
            elseif not handledspinjump and y > self.spinjump_button.pos.y and y < self.spinjump_button.pos.y + self.spinjump_button.size.y and x > self.spinjump_button.pos.x and x < self.spinjump_button.pos.x + self.spinjump_button.size.x then
                self.spinjump = true
                handledspinjump = true
            elseif not handledsavestate and y > self.savestate_button.pos.y and y < self.savestate_button.pos.y + self.savestate_button.size.y and x > self.savestate_button.pos.x and x < self.savestate_button.pos.x + self.savestate_button.size.x then
                self.savestate = true
                handledsavestate = true
            elseif not handledloadstate and y > self.loadstate_button.pos.y and y < self.loadstate_button.pos.y + self.loadstate_button.size.y and x > self.loadstate_button.pos.x and x < self.loadstate_button.pos.x + self.loadstate_button.size.x then
                self.loadstate = true
                handledloadstate = true
            elseif not handledrun and y > self.run_button.pos.y and y < self.run_button.pos.y + self.run_button.size.y and x > self.run_button.pos.x and x < self.run_button.pos.x + self.run_button.size.x then
                self.run = true
                handledrun = true
            elseif not handledreset and y > self.reset_button.pos.y and y < self.reset_button.pos.y + self.reset_button.size.y and x > self.reset_button.pos.x and x < self.reset_button.pos.x + self.reset_button.size.x then
                self.reset = true
                handledreset = true
            else
                x, y = push.toGame(x,y)

                if x and y then
                    self.mouse_x = x
                    self.mouse_y = y
                    self.mouse_click = true
                end
            end

            
            ::continue::
        end
    end
end

function InputHandler:InitLOVEMobileGamepad()

    self.mobile_ui_image = KaizoImage:new()
    self.mobile_ui_image:load("data/images/mobile/ui.png")

    if not self.mobile_ui_image then
        error("could not find mobile ui image")
    end

    self:RecalculateLOVEMobileButtonPostions()

end

function InputHandler:RecalculateLOVEMobileButtonPostions()
    self.joystick = {pos = {x = 20, y = RealWindowSize.y - (RealWindowSize.y/2 + 20)}, size = {x = (RealWindowSize.y/2), y = (RealWindowSize.y/2)}}
    self.spinjump_button = {pos = {x = RealWindowSize.x - ((RealWindowSize.y/4) + 51), y = RealWindowSize.y - (RealWindowSize.y/2 + 20)}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/4}}
    self.jump_button = {pos = {x = RealWindowSize.x - ((RealWindowSize.y/4) + 51), y = RealWindowSize.y - (RealWindowSize.y/4 + 20)}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/4}}
    self.run_button = {pos = {x = RealWindowSize.x - ((RealWindowSize.y/2) + 51), y = RealWindowSize.y - (RealWindowSize.y/4 + 20)}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/4}}
    self.reset_button = {pos = {x = RealWindowSize.x/2 - (RealWindowSize.y/2 + 10), y = 10}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/8}}
    self.savestate_button = {pos = {x = RealWindowSize.x/2 - (RealWindowSize.y/8), y = 10}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/8}}
    self.loadstate_button = {pos = {x = RealWindowSize.x/2 + (RealWindowSize.y/4 + 10), y = 10}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/8}}
end

function InputHandler:DrawLOVEMobileGamepad()

    self.mobile_ui_image:render_scaled_from_to(0, 0, 64, 64, self.joystick.pos.x, self.joystick.pos.y, self.joystick.size.x, self.joystick.size.y)

    self.mobile_ui_image:render_scaled_from_to(64, 0, 31, 31, self.spinjump_button.pos.x, self.spinjump_button.pos.y, self.spinjump_button.size.x, self.spinjump_button.size.y)

    self.mobile_ui_image:render_scaled_from_to(64, 0, 31, 31, self.jump_button.pos.x, self.jump_button.pos.y, self.jump_button.size.x, self.jump_button.size.y)

    self.mobile_ui_image:render_scaled_from_to(64, 31, 31, 31, self.run_button.pos.x, self.run_button.pos.y, self.run_button.size.x, self.run_button.size.y)

    self.mobile_ui_image:render_scaled_from_to(95, 0, 31, 17, self.reset_button.pos.x, self.reset_button.pos.y, self.reset_button.size.x, self.reset_button.size.y)

    self.mobile_ui_image:render_scaled_from_to(95, 17, 31, 17, self.savestate_button.pos.x, self.savestate_button.pos.y, self.savestate_button.size.x, self.savestate_button.size.y)

    self.mobile_ui_image:render_scaled_from_to(95, 17, 31, 17, self.loadstate_button.pos.x, self.loadstate_button.pos.y, self.loadstate_button.size.x, self.loadstate_button.size.y)
end