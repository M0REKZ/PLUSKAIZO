-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("common.kaizo_collision")

IS_MOBILE = false

Lives = 0
GameContext = 0

Camera = {x = 0, y = 0}
WindowSize = {x = 768, y = 512}

function FitCameraToSize(size)
    if Camera.x < 0 then
        Camera.x = 0
    end

    if Camera.y < 0 then
        Camera.y = 0
    end

    if Camera.x + WindowSize.x > size.x * 32 then
        Camera.x = size.x * 32 - WindowSize.x
    end

    if Camera.y + WindowSize.y > size.y * 32 then
        Camera.y = size.y * 32 - WindowSize.y
    end
end