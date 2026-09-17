--[[
    PLUSKAIZO
    Copyright (c) Benjamín Gajardo All rights reserved

    You are not allowed to use or read this code without my explicit permission
--]]

local json = require("external.dkjson")

KaizoJSONHandler = {}

function KaizoJSONHandler:ToJSON(val)
    return json.encode(val)
end

function KaizoJSONHandler:FromJSON(str)
    return json.decode(str)
end