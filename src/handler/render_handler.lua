-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

RenderHandler = {}

RenderHandler.MainFont = nil

function RenderHandler:InitFont()
    RenderHandler.MainFont = love.graphics.newFont("data/images/Snowstorm.otf",15)
end

function RenderHandler:Print(text,x,y)
    love.graphics.setFont(RenderHandler.MainFont)
    love.graphics.print(text,x,y)
end