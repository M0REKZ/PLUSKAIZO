-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common/kaizo_image")
require("common/kaizo_collision")
require("common.kaizo_globals")

KaizoDeathEffect = setmetatable({}, {__index = KaizoSquare})

KaizoDeathEffect.name = "KaizoDeathEffect"
KaizoDeathEffect.__index = KaizoDeathEffect

function KaizoDeathEffect:new(x, y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoDeathEffect)

    o.size.x = 32
    o.size.y = 32

    o.col.up = 0
    o.col.down = 0
    o.col.left = 0
    o.col.right = 0

    o.active_out_of_camera = true
    o.dont_fall = false
    o.lifetime = -1
    o.flip = true


    o.image_id = 0 -- Default image ID for the square
    o.image = nil

    return o
end

function KaizoDeathEffect:update()

    if self.die then
        self:destroy()
        return
    end

    if not self.dont_fall and self.vel.y < 15 then --max fall vel
        self.vel.y = self.vel.y + 1
    end

    -- Update logic for the square entity
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y

    if not IsPosInCamera(self.pos, self.size) then
        self.die = true
    end

    if self.lifetime > 0 then
        self.lifetime = self.lifetime - 1
    elseif self.lifetime == 0 then
        self.die = true
    end
    
end

function KaizoDeathEffect:render()

    if (not self.image) and not (self.image_id == 0) then
        self.image = GameContext.CurrentLevel:get_entity_image(self.image_id)
        if not self.image then
            local image = KaizoImage:new()
            image:load_entity_image_by_id(o.image_id)
            GameContext.CurrentLevel:add_entity_image(image)
            self.image = image
        end
    end

    -- Render logic for the square entity
    if(self.image) then
        if self.flip then
            self.image:render_incamera_scaled_from_to(0, 0, self.size.x, self.size.y, self.pos.x, self.pos.y + self.size.y, self.size.x, self.size.y * -1)
        else
            self.image:render_incamera_from_to(0, 0, self.size.x, self.size.y, self.pos.x, self.pos.y)
        end
    else
        error("Image not loaded for KaizoSquare with ID: " .. tostring(self.image_id))
    end
end