-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

local json = require("external.json")

KaizoJSONHandler = {}

function KaizoJSONHandler:ToJSON(val)
    return json.encode(val)
end

function KaizoJSONHandler:FromJSON(str)
    return json.decode(str)
end