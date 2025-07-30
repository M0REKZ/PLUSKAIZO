-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("handler.json_handler")
require("common.entities.kaizo_entity_list")

KaizoLevelHandler = {}

function KaizoLevelHandler:LoadSectionFromString(str)
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
    GameContext.CurrentLevel = KaizoLevel:new()

    for num = 1, 100, 1 do --max 100 sections
        local str = love.filesystem.read("data/levels/" .. name .. "/section_" .. num .. ".json")
        if not str then
            --try tmj
            str = love.filesystem.read("data/levels/" .. name .. "/section_" .. num .. ".tmj")
            if not str then
                break
            end
        end
        local newsection = self:LoadSectionFromString(str)
        GameContext.CurrentLevel:add_section(newsection)
        if newsection.is_initial_section then
            GameContext.CurrentLevel:set_current_section(num)
        end
    end
    if GameContext.CurrentLevel.CurrentSection == 0 then
        GameContext.CurrentLevel:set_current_section(1)
    end

    local sec = GameContext.CurrentLevel:get_current_section()

    if sec.Music then
        sec.Music:Loop()
        sec.Music:Play()
    end

    GameContext.CurrentLevel.Name = name
end