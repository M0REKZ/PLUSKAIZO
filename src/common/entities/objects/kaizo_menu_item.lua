-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common/kaizo_image")
require("common/kaizo_collision")
require("common.kaizo_globals")

KaizoMenuItem = {name = "KaizoMenuItem"}

function KaizoMenuItem:new(x, y)
    local o = {}
    setmetatable(o,KaizoMenuItem)
    self.__index = KaizoMenuItem

    o.marked_for_deletion = false

    o.pos = KaizoLocation:new(x, y)
    o.size = {x = 256, y = 128}

    o.image_id = 0
    o.image_path = "data/images/pluskzlogo.png"
    o.image = nil
    o.item = 0
    o.can_load_level_properties = true

    return o
end

function KaizoMenuItem:update()
    if self.item > 0 and InputHandler.mouse_click and InputHandler.mouse_x > self.pos.x and InputHandler.mouse_x < self.pos.x + self.size.x and InputHandler.mouse_y > self.pos.y and InputHandler.mouse_y < self.pos.y + self.size.y then
        if self.item == 1 then
            GameContext.QueuedLevelName = "level1"
            return
        elseif self.item == 2 then
            GameContext.Quit = true
            return
        end

    end
end

function KaizoMenuItem:render()
    if not self.image then
        self.image = KaizoImage:new()
        self.image:load(self.image_path)
        GameContext.CurrentLevel:add_entity_image(self.image)
    end

    if self.image then
        if self.item == 0 then
            self.image:render_scaled_to(self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.item == 1 then
            self.image:render_scaled_from_to(0,0,88,42,self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.item == 2 then
            self.image:render_scaled_from_to(0,41,188,42,self.pos.x, self.pos.y, self.size.x, self.size.y)
        end
    end
end

function KaizoMenuItem:destroy()
    self.marked_for_deletion = true
end

function KaizoMenuItem:SaveState()
    return {
        name = self.name,
        pos = self.pos,
        size = self.size,
        marked_for_deletion = self.marked_for_deletion,
        image_path = self.image_path,
        item = self.item,
    }
end

function KaizoMenuItem:LoadState(state)
    self.name = state.name
    self.pos = state.pos
    self.size = state.size
    self.marked_for_deletion = state.marked_for_deletion
    self.image_path = state.image_path
    self.item = state.item
end

function KaizoMenuItem:HandleProperty(prop)
    if prop.name == "item" then
        self.item = prop.value
    elseif prop.name == "sizex" then
        self.size.x = prop.value
    elseif prop.name == "sizey" then
        self.size.y = prop.value
    end

    if self.item > 0 then
        self.image_path = "data/images/ui_menu.png"
    end
end