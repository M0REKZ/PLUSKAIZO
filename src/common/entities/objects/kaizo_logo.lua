-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common/kaizo_image")
require("common/kaizo_collision")
require("common.kaizo_globals")

KaizoLogo = {name = "KaizoLogo"}

function KaizoLogo:new(x, y)
    local o = {}
    setmetatable(o,KaizoLogo)
    self.__index = KaizoLogo

    o.marked_for_deletion = false

    --o.pos = KaizoLocation:new(x, y)

    o.image_id = 0
    o.image_path = "data/images/kzlogo.png"
    o.image = nil
    o.framestowait = 60
    o.nextsection = 1

    return o
end

function KaizoLogo:update()
    if not self.image then
        self.image = KaizoImage:new()
        self.image:load(self.image_path)
        GameContext.CurrentLevel:add_entity_image(self.image)
    end

    self.framestowait = self.framestowait - 1

    if self.framestowait <= 0 then
        self:destroy()
        GameContext.CurrentLevel.QueuedSection = self.nextsection
    end
end

function KaizoLogo:render()
    if self.image then
        self.image:render_scaled_to(0 + WindowSize.x/5, 0 + WindowSize.y/5, WindowSize.x - (WindowSize.x/5)*2, WindowSize.y - (WindowSize.y/5)*2)
    end
end

function KaizoLogo:destroy()
    self.marked_for_deletion = true
end

function KaizoLogo:SaveState()
    return {
        name = self.name,
        marked_for_deletion = self.marked_for_deletion,
        image_path = self.image_path,
        framestowait = self.framestowait,
        nextsection = self.nextsection,
    }
end

function KaizoLogo:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.image_path = state.image_path
    self.framestowait = state.framestowait
    self.nextsection = state.nextsection
end