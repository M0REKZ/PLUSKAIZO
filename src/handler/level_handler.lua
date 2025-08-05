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

require("handler.json_handler")
require("common.entities.kaizo_entity_list")
require("lib.kaizo_lvlx_reader")
require("common.kaizo_collision")
require("handler.file_handler")

KaizoLevelHandler = {}

function KaizoLevelHandler:LoadTMJSectionFromString(str)
    local sectiondata = KaizoJSONHandler:FromJSON(str)
    local newsection = KaizoSection:new()
    if sectiondata then
        if sectiondata.type == "map" then
            newsection.Size.x = sectiondata.width
            newsection.Size.y = sectiondata.height
            if sectiondata.properties then
                for index, property in ipairs(sectiondata.properties) do
                    if property.name == "background" then
                        local img = KaizoImage:new()
                        img:load(property.value)
                        newsection.Background = img
                    elseif property.name == "is_initial_section" then
                        newsection.is_initial_section = property.value
                    elseif property.name == "music" then
                        local mus = KaizoSound:new()
                        mus:Load(property.value)
                        newsection.Music = mus
                    end
                end
            end
            for num, group in ipairs(sectiondata.layers) do
                if group.type == "group" then
                    local newlayer = KaizoLayer:new()
                    for num2, layer in ipairs(group.layers) do
                        if layer.type == "tilelayer" then
                            newlayer:set_tiles(layer.data,layer.width,layer.height)
                        elseif layer.type == "objectgroup" then
                            local namefound
                            local ent
                            for num3, obj in ipairs(layer.objects) do
                                namefound = false
                                ent = nil
                                if obj.properties then --hating how tiled works
                                    for index, property in ipairs(obj.properties) do
                                        if property.name == "name" then
                                            ent = KaizoEntitiesCreator[property.value]:new(math.floor(obj.x),math.floor(obj.y))
                                            newlayer:add_entity(ent)
                                            namefound = true
                                        end
                                    end
                                end
                                if not namefound then --name could be there too, in case it is not in the custom properties
                                    ent = KaizoEntitiesCreator[obj.name]:new(obj.x,obj.y)
                                    newlayer:add_entity(ent)
                                end

                                if obj.properties and ent and ent.can_load_level_properties then --for extra properties, handling after entity creation
                                    for index, property in ipairs(obj.properties) do
                                        ent:HandleProperty(property)
                                    end
                                end
                            end
                        else
                            print("warning: layer " .. num2 .. " has unknown type, ignoring...")
                        end
                    end
                    newsection:add_layer(newlayer)
                    
                else
                    error("error reading section data for KaizoLayer: group " .. num .. " is not a group")
                end
            end
        else
            error("error reading section data for KaizoSection: map table not found")
        end
    else
        error("error reading level data")
    end

    return newsection
end

function KaizoLevelHandler:LoadLevelFromName(name)
    love.audio.stop()
    GameContext.CurrentLevel = nil

    local str = "data/levels/" .. name .. ".lvlx"

    if KaizoFileHandler:FileExists(str) then
        local lvlxdata = KaizoLVLXReader:ReadLVLX(str)
        GameContext.CurrentLevel = KaizoLevel:new()
        self:LoadLVLXLevelFromTable(lvlxdata) --Load entire level from lvlx
    else
        GameContext.CurrentLevel = KaizoLevel:new() --Create level by myself, we will add sections from tmj
        for num = 1, 100, 1 do --max 100 sections
            local str = KaizoFileHandler:GetFileAsString("data/levels/" .. name .. "/section_" .. num .. ".json")
            if not str then
                --try tmj
                str = KaizoFileHandler:GetFileAsString("data/levels/" .. name .. "/section_" .. num .. ".tmj")
                if not str then
                    break
                end
            end
            local newsection = self:LoadTMJSectionFromString(str)
            GameContext.CurrentLevel:add_section(newsection)
            if newsection.is_initial_section then
                GameContext.CurrentLevel:set_current_section(num)
            end
        end
    end

    if GameContext.CurrentLevel.CurrentSection == 0 then
        print("No current section set, fallback to section 1")
        GameContext.CurrentLevel:set_current_section(1)
    end

    local sec = GameContext.CurrentLevel:get_current_section()

    if sec.Music then
        sec.Music:Loop()
        sec.Music:Play()
    end

    GameContext.CurrentLevel.Name = name
end

function KaizoLevelHandler:LoadLVLXLevelFromTable(lvlxdata)
    local templevel = GameContext.CurrentLevel

    local tempsectiondata = {}
    local temptilelayers = {} --temptilelayers[section][layer][tile]
    local layerhastiles = {}

    local gamename = "\"TheXTech\""
    if lvlxdata.Head then
        for num, head_element in ipairs(lvlxdata.Head) do
            if head_element["CPID"] then
                gamename = head_element["CPID"]
            end
        end
    end

    if lvlxdata.Sections then
        local tempsection = nil
        for num, lvlxsection in ipairs(lvlxdata.Sections) do
            tempsection = KaizoSection:new()
            tempsectiondata[num] = {}

            --both offsets used to calculate tiles and entities positions and the section they belong to
            --since PLUSKAIZO does not have sections in a same "world", unlike SMBX engine
            tempsectiondata[num].x = tonumber(lvlxsection["L"]) --x offset
            tempsectiondata[num].y = tonumber(lvlxsection["T"]) --y offset
            tempsectiondata[num].w = tonumber(lvlxsection["R"]) - tonumber(lvlxsection["L"]) --get section size this way...
            tempsectiondata[num].h = tonumber(lvlxsection["B"]) - tonumber(lvlxsection["T"]) --get section size this way...

            tempsection.Size.x = math.ceil(tempsectiondata[num].w / 32) --...so i can set it on the PLUSKAIZO section
            tempsection.Size.y = math.ceil(tempsectiondata[num].h / 32) --...so i can set it on the PLUSKAIZO section

            templevel:add_section(tempsection)
            tempsection = nil
        end

        if lvlxdata.Layers then
            
            local templayer = nil

            for num, lvlxlayer in ipairs(lvlxdata.Layers) do
                templayer = KaizoLayer:new()
                templayer.name = lvlxlayer["LR"] --save layer name, so we can identify it

                --add layer to all sections
                --why!?!?!? because SMBX has layers globally, but PLUSKAIZO have them inside each section
                --so trying to keep compatibility we do this
                --of course can be improved...
                for i = 1, #templevel.Sections, 1 do
                    templevel.Sections[i]:add_layer(templayer)
                end
                templayer = nil
            end

        end

        if lvlxdata.Blocks then
            
            --here is the hard thing, we need to check blocks positions to know in which section they belong to.
            --and we need to divide the position by 32 to set them in a unidimensional array of tiles that uses 0 for
            --empty tiles...

            --sadly, we CAN NOT know to which section belong the blocks that are OUTSIDE a LVLX section.
            --if someone can help solving this, pull requests are welcome

            --init tile layers
            for i = 1, #templevel.Sections, 1 do
                temptilelayers[i] = {}
                layerhastiles[i] = {}
                for j = 1, #templevel.Sections[i].Layers, 1 do
                    temptilelayers[i][j] = {}
                    layerhastiles[i][j] = false
                    for k = 1, templevel.Sections[i].Size.x * templevel.Sections[i].Size.y, 1 do
                        temptilelayers[i][j][k] = 0
                    end
                end
            end

            local blockpos = {x = -1, y = -1}
            local blockposinsection = {x = -1, y = -1}
            local lvlxlayername = nil
            local id = 0
            local entityname = nil
            local multiid = false --for big blocks with size divisible by 32
            local squaresize = {x = 32, y = 32} -- for blocks that are not divisible by 32
            local isonbackground = false
            for num, block in ipairs(lvlxdata.Blocks) do
                blockpos = {x = tonumber(block["X"]),y = tonumber(block["Y"])}
                lvlxlayername = block["LR"]

                squaresize.x = tonumber(block["W"])
                squaresize.y = tonumber(block["H"])

                if squaresize.x % 32 > 0 or squaresize.x % 32 > 0 then
                    entityname = "KaizoSquare"
                end


                id = tonumber(block["ID"])

                if gamename == "\"TheXTech\"" then --convert to PLUSKAIZO counterpart
                    if id == 3 then
                        id = 2
                    elseif id == 6 then
                        id = 3
                    elseif id == 7 then
                        id = 1
                    elseif id == 15 then
                        id = 4
                    elseif id == 16 then
                        id = 5
                    elseif id == 17 then
                        id = 6
                    elseif id == 274 then
                        id = 7
                    elseif id == 275 then
                        id = 8
                    elseif id == 276 then
                        id = 9
                    elseif id == 110 then
                        id = 10
                    elseif id == 601 then
                        id = 12
                    elseif id == 600 then
                        id = 13
                    elseif id == 269 then
                        id = 14
                    elseif id == 268 then
                        id = 15
                    elseif id == 267 then
                        id = 16
                    elseif id == 1 then
                        id = 17
                    elseif id == 4 then
                        id = 0
                        entityname = "KaizoGlass"
                    elseif id == 25 or id == 26 or id == 27 or id == 28 then --resizable thextech blocks
                        id = 0
                        entityname = "KaizoSquareResize"
                        isonbackground = true
                    elseif id == 604 or id == 605 or id == 21 or id == 22 then --big blocks divisible by 32
                        multiid = true
                    else
                        id = 11 -- unidentified block
                    end
                end

                for num2, section in ipairs(templevel.Sections) do
                    blockposinsection = {x = blockpos.x - tempsectiondata[num2].x, y = blockpos.y - tempsectiondata[num2].y}
                    if IsPointInsideSquare(blockposinsection.x,blockposinsection.y,0,0,section.Size.x*32,section.Size.y*32) then
                        local layerfound = false
                        for num3, layer in ipairs(section.Layers) do
                            if layer.name == lvlxlayername then
                                if not entityname then
                                    if not multiid then
                                        temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = id
                                    else
                                        if gamename == "\"TheXTech\"" then
                                            if id == 604 then
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 20
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 21
                                            elseif id == 605 then
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 18
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 19
                                            elseif id == 21 then
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 22
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 23
                                            elseif id == 22 then
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 24
                                                temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 25
                                            end
                                        end
                                    end
                                    layerhastiles[num2][num3] = true
                                    layerfound = true
                                else
                                    local ent = nil
                                    if entityname == "KaizoSquare" or entityname == "KaizoSquareResize" then
                                        ent = KaizoEntitiesCreator[entityname]:new(blockposinsection.x, blockposinsection.y, squaresize.x, squaresize.y)
                                        ent.is_on_background = isonbackground
                                    else
                                        ent = KaizoEntitiesCreator[entityname]:new(blockposinsection.x, blockposinsection.y)
                                        ent.is_on_background = isonbackground
                                    end
                                    layer:add_entity(ent)
                                    layerfound = true
                                    entityname = nil
                                end
                                break
                            end
                        end
                        if not layerfound then
                            for num3, layer in ipairs(section.Layers) do
                                if layer.name == "\"Default\"" then
                                    if not entityname then
                                        if not multiid then
                                            temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = id
                                        else
                                            if gamename == "\"TheXTech\"" then
                                                if id == 604 then
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 20
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 21
                                                elseif id == 605 then
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 18
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 19
                                                elseif id == 21 then
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 22
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 23
                                                elseif id == 22 then
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 1] = 24
                                                    temptilelayers[num2][num3][((math.floor(blockposinsection.y / 32) * section.Size.x + math.floor(blockposinsection.x / 32))) + 2] = 25
                                                end
                                            end
                                        end
                                        layerhastiles[num2][num3] = true
                                        layerfound = true
                                    else
                                        local ent = nil
                                        if entityname == "KaizoSquare" or entityname == "KaizoSquareResize" then
                                            ent = KaizoEntitiesCreator[entityname]:new(blockposinsection.x, blockposinsection.y, squaresize.x, squaresize.y)
                                            ent.is_on_background = isonbackground
                                        else
                                            ent = KaizoEntitiesCreator[entityname]:new(blockposinsection.x, blockposinsection.y)
                                            ent.is_on_background = isonbackground
                                        end
                                        layer:add_entity(ent)
                                        layerfound = true
                                        entityname = nil
                                    end
                                    break
                                end
                            end
                        end

                        break
                    end
                end
                squaresize = {x = 32, y = 32}
                multiid = false
                isonbackground = false
            end

            --set tiles on each layer

            for num1, section in ipairs(templevel.Sections) do
                if num1 > 1 then
                    break
                end
                for num2, layer in ipairs(section.Layers) do
                    if layerhastiles[num1][num2] then
                        layer:set_tiles(temptilelayers[num1][num2], templevel.Sections[num1].Size.x, templevel.Sections[num1].Size.y)
                    end
                end
            end
        end

        if lvlxdata.NPCs then
            

            local npcpos = {x = -1, y = -1}
            local npcposinsection = {x = -1, y = -1}
            local lvlxlayername = nil
            local id = 0
            local name = "KaizoSquare"
            for num, npc in ipairs(lvlxdata.NPCs) do
                npcpos = {x = tonumber(npc["X"]),y = tonumber(npc["Y"])}
                lvlxlayername = npc["LR"]

                id = tonumber(npc["ID"])
                

                if gamename == "\"TheXTech\"" then --convert to PLUSKAIZO counterpart
                    if id == 1 or id == 2 or id == 27 or id == 98 or id == 242 then
                        name = "KaizoTomate"
                    elseif id == 47 then
                        name = "KaizoChicken"
                    else
                        name = "KaizoSquare" -- unidentified npc
                    end
                elseif gamename == "PLUSKAIZO" then
                    if id == 1 then
                        name = "KaizoSquare"
                    elseif id == 2 then
                        name = "KaizoPlayer"
                    elseif id == 3 then
                        name = "KaizoEGG"
                    end
                end

                for num2, section in ipairs(templevel.Sections) do
                    npcposinsection = {x = npcpos.x - tempsectiondata[num2].x, y = npcpos.y - tempsectiondata[num2].y}
                    if IsPointInsideSquare(npcposinsection.x,npcposinsection.y,0,0,section.Size.x*32,section.Size.y*32) then
                        local layerfound = false
                        for num3, layer in ipairs(section.Layers) do
                            if layer.name == lvlxlayername then
                                local ent = KaizoEntitiesCreator[name]:new(npcposinsection.x, npcposinsection.y)
                                layer:add_entity(ent)
                                layerfound = true
                                break
                            end
                        end
                        if not layerfound then
                            for num3, layer in ipairs(section.Layers) do
                                if layer.name == "\"Default\"" then
                                    local ent = KaizoEntitiesCreator[name]:new(npcposinsection.x, npcposinsection.y)
                                    layer:add_entity(ent)
                                    layerfound = true
                                    break
                                end
                            end
                        end

                        break
                    end
                end
            end
        end

        if lvlxdata.StartPoints then
            local startpos = {x = -1, y = -1}
            local startposinsection = {x = -1, y = -1}
            local foundstart = false
            for num, startpoint in ipairs(lvlxdata.StartPoints) do
                startpos = {x = tonumber(startpoint["X"]),y = tonumber(startpoint["Y"])}
                for num2, section in ipairs(templevel.Sections) do
                    startposinsection = {x = startpos.x - tempsectiondata[num2].x,y = startpos.y - tempsectiondata[num2].y}
                    if IsPointInsideSquare(startposinsection.x,startposinsection.y,0,0,section.Size.x*32,section.Size.y*32) then
                        templevel:set_current_section(num2)
                        foundstart = true
                        break

                    end
                    if foundstart then
                        break
                    end
                end

                if foundstart then
                    local player = KaizoPlayer:new(startposinsection.x, startposinsection.y)
                    for num3, layer in ipairs(templevel:get_current_section().Layers) do
                        if layer.name == "\"Default\"" then
                            layer:add_entity(player)
                            break
                        end
                    end
                    break
                end
            end
        end
    end

    return templevel
end