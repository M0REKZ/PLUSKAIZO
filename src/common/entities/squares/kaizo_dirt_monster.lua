-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common.entities.kaizo_square")
require("common.kaizo_collision")
require("common.kaizo_globals")
require("common.kaizo_sound")

KaizoDirtMonster = setmetatable({}, {__index = KaizoEGG})
KaizoDirtMonster.name = "KaizoDirtMonster"

KaizoDirtMonster.__index = KaizoDirtMonster

function KaizoDirtMonster:new(x,y)
    local o = KaizoEGG:new(x-64,y-64)
    o = setmetatable(o,KaizoDirtMonster)

    o.col.up = 4
    o.col.down = 4
    o.col.left = 4
    o.col.right = 4

    o.size.x = 128
    o.size.y = 128

    o.image_id = 5 -- Default image ID for KaizoTomate
    o.image = nil
    o.can_collide_square = true
    o.has_collision_square = true
    o.is_player = false
    o.is_npc = true
    o.going_left = false
    o.going_right = false
    o.jumped = false
    o.die = false
    o.grounded = false
    o.can_die = true
    o.dir = -1
    o.frame = 0
    o.frametime = 0
    o.sec = 0
    o.is_edge_careful = false
    o.hidden = true

    o.can_load_level_properties = true

    o.death_sound = GameContext.CurrentLevel:get_sound(5)

    if not o.death_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(5)
        GameContext.CurrentLevel:add_sound(sound)
        o.death_sound = sound
    end

    return o
end

function KaizoDirtMonster:render()

    if not self.image then
        self.image = GameContext.CurrentLevel:get_entity_image(self.image_id)
        if not self.image then
            if not self.image then
                local image = KaizoImage:new()
                image:load_entity_image_by_id(self.image_id)
                GameContext.CurrentLevel:add_entity_image(image)
                self.image = image
            end
        end
    end

    if(self.image) then

        self.frametime = self.frametime + 1
		
		if(self.frametime > 4) then
		
			self.frame = self.frame + 1
			self.frametime = 0
        end
		
		if(self.frame > 7) then
			self.frame = 0
        end
		
		self.image:render_incamera_scaled_from_to()

    else
        error("Image not loaded for KaizoDirtMonster with ID: " .. tostring(self.image_id))
    end
end


function KaizoDirtMonster:HandleProperty(prop)
    if prop.name == "is_edge_careful" then
        self.is_edge_careful = prop.value
    end

    if self.is_edge_careful then
        self.image_id = 6
    end
end

function KaizoDirtMonster:HandlePlayerCollision(player, collide)
    if collide.down == 4 then
        player.vel.y = -7
        self.die = true
    end
end