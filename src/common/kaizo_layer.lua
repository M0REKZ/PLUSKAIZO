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

require("common/kaizo_image")
require("common/kaizo_globals")
require("common.entities.kaizo_entity_list")

KaizoLayer = {}

function KaizoLayer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.Entities = {}
    o.Tiles = {}
    o.Width = 0
    o.Height = 0
    o.Offset = {x = 0, y = 0}
    return o
end

function KaizoLayer:update()
    -- Update logic for the layer
    for _, entity in ipairs(self.Entities) do
        if entity.active_out_of_camera or IsPosInCamera(entity.pos or Camera, entity.size or {x = 0,y = 0}) then
            entity.active = true
            entity:update()
        else
            entity.active = false
        end
    end

    --post update, check to delete entities
    self:check_deleted_entities()
end

function KaizoLayer:check_deleted_entities()
    for num = #self.Entities, 1, -1 do
        if self.Entities[num].marked_for_deletion then
            table.remove(self.Entities,num)
        end
    end
end

function KaizoLayer:render_back()
    -- Render logic for the layer
    for _, entity in ipairs(self.Entities) do
        if not entity.is_on_background then
            goto continue
        end
        if IsPosInCamera(entity.pos or Camera, entity.size or {x = 0,y = 0}) or entity.always_render then
            entity:render()
        end
        ::continue::
    end
end

function KaizoLayer:render()
    -- Render logic for the layer
    for num, tile in ipairs(self.Tiles) do
        if tile > 0 then
            local pos = {x = ((num - 1) % (self.Width)) * 32 + self.Offset.x, y = math.floor((num - 1)/(self.Width)) * 32 + self.Offset.y}
            if IsInCamera(pos.x, pos.y, 32, 32) then
                KaizoContext.CurrentLevel:get_tile_image(tile):render_incamera_scaled_to(pos.x, pos.y, 32, 32)
            end
        end
    end
    for _, entity in ipairs(self.Entities) do
        if entity.is_on_background then
            goto continue
        end
        if IsPosInCamera(entity.pos or Camera, entity.size or {x = 0,y = 0}) or entity.always_render then
            entity:render()
        end
        ::continue::
    end
end

function KaizoLayer:add_entity(entity)
    self.Entities[#self.Entities + 1] = entity
    entity.ref_layer = self
    if entity.image_id > 0 and not KaizoContext.CurrentLevel:get_entity_image(entity.image_id) then
        local image = KaizoImage:new()
        image:load_entity_image_by_id(entity.image_id)
        KaizoContext.CurrentLevel:add_entity_image(image)
    end
end

function KaizoLayer:remove_entity(entity)
    for num = #self.Entities, 1, -1 do
        if self.Entities[num] == entity then
            self.Entities[num].ref_layer = nil
            table.remove(self.Entities,num)
            break
        end
    end
end

function KaizoLayer:set_tiles(tiles, width, height)
    local temp = width * height
    if #tiles ~= temp then
        error("Tiles array size does not match specified width and height: tiles: " .. tostring(#tiles) .. " vs " .. tostring(temp).."\nwidht: "..width.."\nheight: "..height)
    end
    self.Tiles = tiles
    self.Width = width
    self.Height = height

    for _, tile in ipairs(self.Tiles) do
        if tile > 0 and not KaizoContext.CurrentLevel:get_tile_image(tile) then
            local image = KaizoImage:new()
            image:load_tile_image_by_id(tile)
            KaizoContext.CurrentLevel:add_tile_image(image)
        end
    end
end

function KaizoLayer:get_tile_id(x,y)
    
    local sec = KaizoContext.CurrentLevel:get_current_section()

    if (y > sec.Size.y * 32) then
        return -2
    end
    if (x < 0) or (y < 0) or (x > sec.Size.x * 32) then
        return -1
    end
    if (x + 1 < self.Offset.x) or (y + 1 < self.Offset.y) or (x + 1 > self.Offset.x + self.Width * 32) or (y + 1 > self.Offset.y + self.Height * 32) then
        return 0
    end

    local localx = math.floor((x)/32)
    local localy = math.floor((y)/32)

    localx = localx - math.floor(self.Offset.x/32)
    localy = localy - math.floor(self.Offset.y/32)

    local index = ((self.Width) * localy + localx) + 1

    if index < 1 or index > (self.Height * self.Width) then
        return 0
    end

    return self.Tiles[index]
end

function KaizoLayer:SaveState()
    local temp = {}

    temp.Entities = {}
    temp.Tiles = self.Tiles
    temp.Width = self.Width
    temp.Height = self.Height
    temp.Offset = self.Offset

    for num, ent in ipairs(self.Entities) do
        temp.Entities[num] = ent:SaveState()
    end

    return temp
end

function KaizoLayer:LoadState(state)

    self.Tiles = state.Tiles
    self.Offset = state.Offset
    self.Width = state.Width
    self.Height = state.Height

    for ind, ent in ipairs(state.Entities) do
        self.Entities[ind] = KaizoEntitiesCreator[ent.name]:new()
        self.Entities[ind].ref_layer = self
        self.Entities[ind].LoadState(self.Entities[ind],ent)
    end
    
end