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
        local RealWindowSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
        local x, y

        local joystick = {pos = {x = 20, y = RealWindowSize.y - (RealWindowSize.y/2 + 20)}, size = {x = (RealWindowSize.y/2), y = (RealWindowSize.y/2)}}
        local jump_button = {pos = {x = RealWindowSize.x - ((RealWindowSize.y/4) + 51), y = RealWindowSize.y - (RealWindowSize.y/2 + 20)}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/4}}
        local run_button = {pos = {x = RealWindowSize.x - ((RealWindowSize.y/2) + 51), y = RealWindowSize.y - (RealWindowSize.y/4 + 20)}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/4}}
        local reset_button = {pos = {x = RealWindowSize.x/2 - 40, y = 10}, size = {x = RealWindowSize.y/4, y = RealWindowSize.y/8}}

        local handledjoy = false
        local handledjump = false
        local handledrun = false
        local handledreset = false

        self.down = false
        self.up = false
        self.left = false
        self.right = false
        self.jump = false
        self.run = false
        self.reset = false
        self.mouse_click = false

        for _, id in ipairs(love.touch.getTouches()) do
            x, y = love.touch.getPosition(id)

            if not handledjoy and y > joystick.pos.y and y < joystick.pos.y + joystick.size.y and x > joystick.pos.x and x < joystick.pos.x + joystick.size.x then
                local offsety = y - joystick.pos.y
                local offsetx = x - joystick.pos.x

                if offsetx < joystick.size.x/3 then
                    self.left = true
                end

                if offsetx > (joystick.size.x/3)*2 then
                    self.right = true
                end

                if offsety < joystick.size.y/3 then
                    self.up = true
                end

                if offsety > (joystick.size.y/3)*2 then
                    self.down = true 
                end

                handledjoy = true
            elseif not handledjump and y > jump_button.pos.y and y < jump_button.pos.y + jump_button.size.y and x > jump_button.pos.x and x < jump_button.pos.x + jump_button.size.x then
                self.jump = true
                handledjump = true
            elseif not handledrun and y > run_button.pos.y and y < run_button.pos.y + run_button.size.y and x > run_button.pos.x and x < run_button.pos.x + run_button.size.x then
                self.run = true
                handledrun = true
            elseif not handledreset and y > reset_button.pos.y and y < reset_button.pos.y + reset_button.size.y and x > reset_button.pos.x and x < reset_button.pos.x + reset_button.size.x then
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
end

function InputHandler:DrawLOVEMobileGamepad()

    local RealWindowSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}

    self.mobile_ui_image:render_scaled_from_to(0,0, 64, 64, 20, RealWindowSize.y - (RealWindowSize.y/2 + 20), RealWindowSize.y/2, RealWindowSize.y/2)

    self.mobile_ui_image:render_scaled_from_to(64,0, 31, 31, RealWindowSize.x - ((RealWindowSize.y/4) + 51), RealWindowSize.y - (RealWindowSize.y/2 + 20), RealWindowSize.y/4, RealWindowSize.y/4)

    self.mobile_ui_image:render_scaled_from_to(64,31, 31, 31, RealWindowSize.x - ((RealWindowSize.y/2) + 51), RealWindowSize.y - (RealWindowSize.y/4 + 20), RealWindowSize.y/4, RealWindowSize.y/4)

    self.mobile_ui_image:render_scaled_from_to(95,0, 31, 17, RealWindowSize.x/2 - 40, 10, RealWindowSize.y/4, RealWindowSize.y/8)
end