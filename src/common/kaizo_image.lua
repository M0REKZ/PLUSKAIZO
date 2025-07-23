-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

KaizoImage = {
    image = nil,
    love2d_quad = nil,
    id = 0,
    width = 0,
    height = 0,
    image_path = "",
}

function KaizoImage:new()
    local o = {}
    setmetatable(o, KaizoImage)
    self.__index = KaizoImage
    return o
end

function KaizoImage:load(imagePath)
    self.image = love.graphics.newImage(imagePath)
    if not self.image then
        error("Failed to load image: " .. imagePath)
    end
    self.image_path = imagePath -- for save states
    self.love2d_quad = love.graphics.newQuad(0, 0, self.image:getWidth(), self.image:getHeight(), self.image)
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function KaizoImage:load_entity_image_by_id(id)
    local imagePath = "data/images/entities/entity_" .. tostring(id) .. ".png"
    self.id = id
    self:load(imagePath)
end

function KaizoImage:load_tile_image_by_id(id)
    local imagePath = "data/images/tiles/tile_" .. tostring(id) .. ".png"
    self.id = id
    self:load(imagePath)
end

function KaizoImage:render_to(x, y)
    if self.image then
        love.graphics.draw(self.image, x, y)
    else
        error("Image not loaded: " .. tostring(self.id))
    end
end

function KaizoImage:render_scaled_to(x, y, scaleX, scaleY)
    if self.image then
        love.graphics.draw(self.image, x, y, 0, scaleX/self.width, scaleY/self.height)
    else
        error("Image not loaded: " .. tostring(self.id))
    end
    
end

function KaizoImage:render_from_to(x1, y1, scaleX, scaleY, x2, y2)
    if self.image and self.love2d_quad then
        self.love2d_quad:setViewport(x1, y1, scaleX, scaleY)
        love.graphics.draw(self.image, self.love2d_quad, x2, y2)
    else
        error("Image or quad not loaded: " .. tostring(self.id))
    end
end

function KaizoImage:render_scaled_from_to(x1, y1, scaleX, scaleY, x2, y2, scaleX2, scaleY2)
    if self.image and self.love2d_quad then
        self.love2d_quad:setViewport(x1, y1, scaleX, scaleY)
        love.graphics.draw(self.image, self.love2d_quad, x2, y2, 0, scaleX2/scaleX, scaleY2/scaleY)
    else
        error("Image or quad not loaded: " .. tostring(self.id))
    end
end

function KaizoImage:render_incamera_to(x, y)
    if self.image then
        love.graphics.draw(self.image, x - Camera.x, Camera.y)
    else
        error("Image not loaded: " .. tostring(self.id))
    end
end

function KaizoImage:render_incamera_scaled_to(x, y, scaleX, scaleY)
    if self.image then
        love.graphics.draw(self.image, x - Camera.x, y - Camera.y, 0, scaleX/self.width, scaleY/self.height)
    else
        error("Image not loaded: " .. tostring(self.id))
    end
    
end

function KaizoImage:render_incamera_from_to(x1, y1, scaleX, scaleY, x2, y2)
    if self.image and self.love2d_quad then
        self.love2d_quad:setViewport(x1, y1, scaleX, scaleY)
        love.graphics.draw(self.image, self.love2d_quad, x2 - Camera.x, y2 - Camera.y)
    else
        error("Image or quad not loaded: " .. tostring(self.id))
    end
end

function KaizoImage:render_incamera_scaled_from_to(x1, y1, scaleX, scaleY, x2, y2, scaleX2, scaleY2)
    if self.image and self.love2d_quad then
        self.love2d_quad:setViewport(x1, y1, scaleX, scaleY)
        love.graphics.draw(self.image, self.love2d_quad, x2 - Camera.x, y2 - Camera.y, 0, scaleX2/scaleX, scaleY2/scaleY)
    else
        error("Image or quad not loaded: " .. tostring(self.id))
    end
end

function KaizoImage:SaveState()
    return {id = self.id, image_path = self.image_path}
end