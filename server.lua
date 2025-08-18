package.path=package.path.."?.lua;?/init.lua;src/?.lua;src/?/init.lua"

require("common.kaizo_globals")
require("kaizo_context")
require("common.kaizo_level")
require("handler.file_handler")

local running = true
IS_KAIZO_SERVER = true

KaizoFileHandler:InitUserPath()
KaizoContext:init()
KaizoLevelHandler:LoadLevelFromName("server")
while running do
    KaizoContext:update_level()
end