-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

require("handler.file_handler") -- to read file line by line

KaizoLVLXReader = {}

function KaizoLVLXReader:ReadLVLX(filepath)

    local HandlingHead = false
    local HandledHead = false

    local HandlingSections = false
    local HandledSections = false

    local HandlingStartPoints = false
    local HandledStartPoints = false

    local HandlingBlocks = false
    local HandledBlocks = false

    local HandlingNPCs = false
    local HandledNPCs = false

    local HandlingLayers = false
    local HandledLayers = false

    local HandlingDoors = false
    local HandledDoors = false

    local LVLXData = {}

    for line in KaizoFileHandler:GetFileLine(filepath) do

        --HEAD
        if line == "HEAD" then
            HandlingHead = true
            goto continue
        elseif line == "HEAD_END" then
            HandledHead = true
            goto continue
        end 
        if HandlingHead and not HandledHead then
            if not LVLXData.Head then
                LVLXData.Head = {}
            end
            local num = #LVLXData.Head + 1
            LVLXData.Head[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.Head[num][key] = value
            end
            goto continue
        end

        --SECTION
        if line == "SECTION" then
            HandlingSections = true
            goto continue
        elseif line == "SECTION_END" then
            HandledSections = true
            goto continue
        end 
        if HandlingSections and not HandledSections then
            if not LVLXData.Sections then
                LVLXData.Sections = {}
            end
            local num = #LVLXData.Sections + 1
            LVLXData.Sections[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.Sections[num][key] = value
            end
            goto continue
        end

        --STARTPOINT
        if line == "STARTPOINT" then
            HandlingStartPoints = true
            goto continue
        elseif line == "STARTPOINT_END" then
            HandledStartPoints = true
            goto continue
        end 
        if HandlingStartPoints and not HandledStartPoints then
            if not LVLXData.StartPoints then
                LVLXData.StartPoints = {}
            end
            local num = #LVLXData.StartPoints + 1
            LVLXData.StartPoints[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.StartPoints[num][key] = value
            end
            goto continue
        end

        --BLOCK
        if line == "BLOCK" then
            HandlingBlocks = true
            goto continue
        elseif line == "BLOCK_END" then
            HandledBlocks = true
            goto continue
        end 
        if HandlingBlocks and not HandledBlocks then
            if not LVLXData.Blocks then
                LVLXData.Blocks = {}
            end
            local num = #LVLXData.Blocks + 1
            LVLXData.Blocks[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.Blocks[num][key] = value
            end
            goto continue
        end

        --NPC
        if line == "NPC" then
            HandlingNPCs = true
            goto continue
        elseif line == "NPC_END" then
            HandledNPCs = true
            goto continue
        end 
        if HandlingNPCs and not HandledNPCs then
            if not LVLXData.NPCs then
                LVLXData.NPCs = {}
            end
            local num = #LVLXData.NPCs + 1
            LVLXData.NPCs[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.NPCs[num][key] = value
            end
            goto continue
        end

        --LAYERS
        if line == "LAYERS" then
            HandlingLayers= true
            goto continue
        elseif line == "LAYERS_END" then
            HandledLayers = true
            goto continue
        end 
        if HandlingLayers and not HandledLayers then
            if not LVLXData.Layers then
                LVLXData.Layers = {}
            end
            local num = #LVLXData.Layers + 1
            LVLXData.Layers[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.Layers[num][key] = value
            end
            goto continue
        end

        --DOORS
        if line == "DOORS" then
            HandlingDoors= true
            goto continue
        elseif line == "DOORS_END" then
            HandledDoors = true
            goto continue
        end 
        if HandlingDoors and not HandledDoors then
            if not LVLXData.Doors then
                LVLXData.Doors = {}
            end
            local num = #LVLXData.Doors + 1
            LVLXData.Doors[num] = {}
            for key, value in string.gmatch(line, "(%w+):(.-);") do
                LVLXData.Doors[num][key] = value
            end
            goto continue
        end

        ::continue::
    end

    return LVLXData
end