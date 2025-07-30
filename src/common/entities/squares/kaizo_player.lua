-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common.entities.kaizo_square")
require("common.kaizo_collision")
require("common.kaizo_globals")
require("handler.input_handler")

KaizoPlayer = setmetatable({}, {__index = KaizoSquare})

KaizoPlayer.name = "KaizoPlayer"

KaizoPlayer.__index = KaizoPlayer

function KaizoPlayer:new(x,y)
    local o = KaizoSquare:new(x,y,32,32)
    o = setmetatable(o,KaizoPlayer)

    o.col.up = 0
    o.col.down = 0
    o.col.left = 0
    o.col.right = 0

    o.size.x = 17
    o.size.y = 31

    o.image_id = 2 -- Default image ID for player
    o.image = GameContext.CurrentLevel:get_entity_image(o.image_id)
    o.can_collide_square = true
    o.has_collision_square = false
    o.is_player = true
    o.going_left = false
    o.going_right = false
    o.jumped = false
    o.die = false
    o.grounded = false
    o.can_die = true
    o.sec = 0
    o.frame = 0
    o.frametime = 0
    o.looking = 1
    o.is_spin_jump = false

    o.active_out_of_camera = true

    o.jump_sound = GameContext.CurrentLevel:get_sound(2)
    o.hurt_sound = GameContext.CurrentLevel:get_sound(3)
    o.spin_jump_sound = GameContext.CurrentLevel:get_sound(4)

    if not o.image then
        local image = KaizoImage:new()
        image:load_entity_image_by_id(o.image_id)
        GameContext.CurrentLevel:add_entity_image(image)
        o.image = image
    end

    if not o.jump_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(2)
        GameContext.CurrentLevel:add_sound(sound)
        o.jump_sound = sound
    end

    if not o.hurt_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(3)
        GameContext.CurrentLevel:add_sound(sound)
        o.hurt_sound = sound
    end

    if not o.spin_jump_sound then
        local sound = KaizoSound:new()
        sound:LoadByID(4)
        GameContext.CurrentLevel:add_sound(sound)
        o.spin_jump_sound = sound
    end

    return o
end

function KaizoPlayer:update()

    self.sec = GameContext.CurrentLevel:get_current_section()

    if self.vel.y < 15 then --max fall vel
        self.vel.y = self.vel.y + 1
    end

    if not self.going_right then
        if InputHandler.left then
            if self.vel.x > -5 or (InputHandler.run and self.vel.x > -10) then
                self.vel.x = self.vel.x - 1
            end
            self.going_left = true
            self.looking = -1
        else
            if self.vel.x < 0 then
                self.vel.x = self.vel.x + 1
            end
            self.going_left = false
        end
    end

    if not self.going_left then
        if InputHandler.right then
            if self.vel.x < 5 or (InputHandler.run and self.vel.x < 10) then
                self.vel.x = self.vel.x + 1
            end
            self.going_right = true
            self.looking = 1
        else
            if self.vel.x > 0 then
                self.vel.x = self.vel.x - 1
            end
            self.going_right = false
        end
    end

    if (not self.jumped) and self.grounded and (InputHandler.jump or InputHandler.spinjump) then
        self.vel.y = -15
        self.jumped = true
        self.jump_sound:Stop()
        self.jump_sound:Play()
        if InputHandler.spinjump then
            self.is_spin_jump = true
            self.spin_jump_sound:Stop()
            self.spin_jump_sound:Play()
        end
    end

   self:do_collision()

    if not self.grounded then
        self.jumped = true
    end

    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y

    Camera.x = (self.pos.x + self.size.x/2) - WindowSize.x/2
    Camera.y = (self.pos.y + self.size.y/2) - WindowSize.y/2

    FitCameraToSize(GameContext.CurrentLevel:get_current_section().Size)

    if self.die then
        self:destroy()
        self.hurt_sound:Play()
        GameContext.DeathLoadState = 50
    end
end

function KaizoPlayer:render()
    if(self.image) then

        --Handle frames
        if self.is_spin_jump then
            if self.frametime < 2 then
                self.looking = -1
            else
                self.looking = 1
            end
            if self.frametime > 4 then
                self.frametime = 3
            end
            self.frame = 0
            self.frametime = self.frametime - 1
        elseif self.vel.y < 0 and not self.grounded then
            self.frame = 4
        elseif self.vel.y > 0 and not self.grounded then
            self.frame = 5
        elseif self.going_left or self.going_right then
            if self.vel.x > 5 or self.vel.x < -5 then
                if self.frametime < 2 then
                    self.frame = 6
                else
                    self.frame = 7
                end

                if self.frametime > 4 then
                    self.frametime = 3
                end
                self.frametime = self.frametime - 1
            else
                if self.frametime < 4 then
                    self.frame = 0
                elseif self.frametime < 8 then
                    self.frame = 1
                elseif self.frametime < 12 then
                    self.frame = 2
                elseif self.frametime < 16 then
                    self.frame = 3
                end

                if self.frametime > 16 then
                    self.frametime = 15
                end
                self.frametime = self.frametime - 1
            end
        else
            self.frame = 0
        end

        if self.frametime == -1 then
            self.frametime = 16
        end

        if self.looking == 1 then
            self.image:render_incamera_from_to(0,32 * self.frame, 25, 32,self.pos.x - 7, self.pos.y - 1)
        else
            self.image:render_incamera_scaled_from_to(0,32 * self.frame, 25, 32,self.pos.x + 25, self.pos.y - 1,-25, 32)
        end
    else
        error("Image not loaded for KaizoSquare with ID: " .. tostring(self.image_id))
    end
end

function KaizoPlayer:destroy()
    self.marked_for_deletion = true
end

function KaizoPlayer:handle_collision(collide, pos2, size2, ent)
    if collide.down == 1 and self.vel.y > 0 then
        self.vel.y = 0
        self.pos.y = pos2.y - self.size.y
        self.jumped = false         --i can jump now
        self.grounded = true
        self.is_spin_jump = false
    elseif not collide.down == 1 and not self.grounded then
        self.grounded = false
    end

    if collide.up == 1 and self.vel.y < 0 then
        self.vel.y = 0
        self.pos.y = pos2.y + size2.y
    end

    if collide.left == 1 and self.vel.x < 0 then
        self.vel.x = 0
        self.pos.x = pos2.x + size2.x
    end

    if collide.right == 1 and self.vel.x > 0 then
        self.vel.x = 0
        self.pos.x = pos2.x - self.size.x
    end

    
    if collide.up == 2 or collide.down == 2 or collide.left == 2 or collide.right == 2 then
        self.die = true
    elseif (collide.up == 3 or collide.down == 3 or collide.left == 3 or collide.right == 3) and ent and ent.can_die then
        ent.die = true
    elseif collide.up == 4 or collide.down == 4 or collide.left == 4 or collide.right == 4 then
        ent:HandlePlayerCollision(self, collide)
    elseif collide.up == 5 or collide.down == 5 or collide.left == 5 or collide.right == 5 then
        self.die = true
    end


    
end

function KaizoPlayer:do_collision()
     --reset some vars before collision
    local collide = nil
    self.grounded = false
    
    for _, layer in ipairs(self.sec.Layers) do
        local temp_tiles = {}
        local tilepos = {}

        tilepos[1] = {x = self.pos.x + self.vel.x, y = self.pos.y + self.vel.y}
        tilepos[2] = {x = self.pos.x + self.vel.x + self.size.x, y = self.pos.y + self.vel.y + self.size.y}
        tilepos[3] = {x = self.pos.x + self.vel.x + self.size.x, y = self.pos.y + self.vel.y}
        tilepos[4] = {x = self.pos.x + self.vel.x, y = self.pos.y + self.vel.y + self.size.y}

        temp_tiles[1] = layer:get_tile_id(tilepos[1].x, tilepos[1].y)
        temp_tiles[2] = layer:get_tile_id(tilepos[2].x, tilepos[2].y)
        temp_tiles[3] = layer:get_tile_id(tilepos[3].x, tilepos[3].y)
        temp_tiles[4] = layer:get_tile_id(tilepos[4].x, tilepos[4].y)

        

        for num, tile in ipairs(temp_tiles) do
            if not (tile == 0) then
                collide = DetectVerticalSquareCollision( self.pos.x, self.pos.y, self.vel.y, self.size.x, self.size.y, tilepos[num].x - (tilepos[num].x % 32), tilepos[num].y - (tilepos[num].y % 32), 32, 32, TileToCollision(tile))
                self:handle_collision(collide, {x = tilepos[num].x - (tilepos[num].x % 32), y = tilepos[num].y - (tilepos[num].y % 32)}, {x = 32, y = 32})
                collide = nil
                collide = DetectHorizontalSquareCollision( self.pos.x, self.pos.y, self.vel.x, self.size.x, self.size.y, tilepos[num].x - (tilepos[num].x % 32), tilepos[num].y - (tilepos[num].y % 32), 32, 32, TileToCollision(tile))
                self:handle_collision(collide, {x = tilepos[num].x - (tilepos[num].x % 32), y = tilepos[num].y - (tilepos[num].y % 32)}, {x = 32, y = 32})
                collide = nil
            end
            ::continue::
        end

        for _, ent in ipairs(layer.Entities) do
            if ent == self then
                goto continue
            end

            if ent.marked_for_deletion then
                goto continue
            end

            if not ent.active then
                goto continue
            end

            if ent.has_collision_square then
                collide = DetectSquareToSquareCollisionQB64OldNew(self.pos.x, self.pos.y, self.pos.x + self.vel.x, self.pos.y + self.vel.y, self.size.x, self.size.y, ent.pos.x, ent.pos.y, ent.size.x, ent.size.y, ent.col)
                self:handle_collision(collide, ent.pos, ent.size, ent)
                collide = {up = 0, down = 0, left = 0, right = 0}
            end

            

            ::continue::
        end
    end
end

function KaizoPlayer:SaveState()
    return {
        name = self.name,
        marked_for_deletion = self.marked_for_deletion,
        pos = {x = self.pos.x, y = self.pos.y},
        size = {x = self.size.x, y = self.size.y},
        vel = {x = self.vel.x, y = self.vel.y},
        col = {up = self.col.up, down = self.col.down, left = self.col.left, right = self.col.right},
        image_id = self.image_id,
        can_collide_square = self.can_collide_square,
        has_collision_square = self.has_collision_square,
        is_player = self.is_player,
        going_left = self.going_left,
        going_right = self.going_right,
        jumped = self.jumped,
        is_spin_jump = self.is_spin_jump,
        die = self.die,
        grounded = self.grounded,
        can_die = self.can_die,
        frame = self.frame,
        frametime = self.frametime,
        looking = self.looking,
        active = self.active,
    }
end

function KaizoPlayer:LoadState(state)
    self.name = state.name
    self.marked_for_deletion = state.marked_for_deletion
    self.pos = state.pos
    self.size = state.size
    self.vel = state.vel
    self.col = state.col
    self.image_id = state.image_id
    self.can_collide_square = state.can_collide_square
    self.has_collision_square = state.has_collision_square

    self.is_player = state.is_player
    self.going_left = state.going_left
    self.going_right = state.going_right
    self.jumped = state.jumped
    self.is_spin_jump = state.is_spin_jump
    self.die = state.die
    self.grounded = state.grounded
    self.can_die = state.can_die
    self.frame = state.frame
    self.frametime = state.frametime
    self.looking = state.looking
    self.active = state.active
    
end
