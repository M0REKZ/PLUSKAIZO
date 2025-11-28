KaizoLevelEditor = {}

function KaizoLevelEditor:init()
    self.menu_active = false
    self.menu_selected = 1
    self.menu_options = {}

    self.selecting_entity = false
    self.selecting_tile = false

    self.setting_section_size = false
    self.setting_section_height = false
    self.original_section_size = nil

    self.setting_level_background = false
    self.setting_level_music = false
    self.setting_level_name = false

    self.editing_entity_properties = false

    self.background_selected = false
    self.music_selected = false

    self.update_layers_size = false

    self.number_input = 0

    self.warning_time = 500

    self.mouse_move_pos = nil
    self.camera_move_pos = nil

    for i = 1, 14, 1 do
        self.menu_options[i] = {}
    end

    self.menu_options[1].text = "Reset Camera"
    self.menu_options[1].func = KaizoLevelEditor.reset_camera
    self.menu_options[2].text = "Set Level Name"
    self.menu_options[2].func = KaizoLevelEditor.set_level_name
    self.menu_options[3].text = "Select Entity"
    self.menu_options[3].func = KaizoLevelEditor.select_entity
    self.menu_options[4].text = "Select Tile"
    self.menu_options[4].func = KaizoLevelEditor.select_tile
    self.menu_options[5].text = "Edit Entity Properties"
    self.menu_options[5].func = KaizoLevelEditor.edit_entity_properties
    self.menu_options[6].text = "Add Section"
    self.menu_options[6].func = KaizoLevelEditor.add_section
    self.menu_options[7].text = "Add Layer to Section"
    self.menu_options[7].func = KaizoLevelEditor.add_layer
    self.menu_options[8].text = "Set Current Section"
    self.menu_options[8].func = KaizoLevelEditor.set_current_section
    self.menu_options[9].text = "Set Current Layer"
    self.menu_options[9].func = KaizoLevelEditor.set_current_layer
    self.menu_options[10].text = "Set Section Size"
    self.menu_options[10].func = KaizoLevelEditor.set_current_section_size
    self.menu_options[11].text = "Set Background"
    self.menu_options[11].func = KaizoLevelEditor.set_background
    self.menu_options[12].text = "Set Music"
    self.menu_options[12].func = KaizoLevelEditor.set_music
    self.menu_options[13].text = "New Level"
    self.menu_options[13].func = KaizoLevelEditor.new_level
    self.menu_options[14].text = "Close Level Editor"
    self.menu_options[14].func = KaizoLevelEditor.close_editor

    self.waiting_for_key_release = false
    self.option_selected = false
    self.entity_selected = false

    self.background = KaizoImage:new()
    self.background:load("data/images/blacksquare.png")

    self.current_layer = 1
    self.current_section = nil

    self.current_tile = nil
    self.current_entity = nil

    self.prev_current_tile = self.current_tile
    self.current_tile_image = KaizoImage:new()

    self.level_background_list = {}
    self.level_music_list = {}

    self.entity_properties_values = nil
end

function KaizoLevelEditor:update()
    if not self.waiting_for_key_release then
        if self.menu_active then
            if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                self.waiting_for_key_release = true
                self.option_selected = true
                self.menu_active = false
                return
            elseif InputHandler.up and self.menu_selected > 1 then
                self.menu_selected = self.menu_selected - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.menu_selected < #self.menu_options then
                self.menu_selected = self.menu_selected + 1
                self.waiting_for_key_release = true
            elseif InputHandler.pause then
                self.menu_active = false
                self.menu_selected = 1
                self.waiting_for_key_release = true
            end
        elseif self.setting_section_size then
            if not self.setting_section_height then
                if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                    self.waiting_for_key_release = true
                    self.setting_section_height = true
                    return
                elseif InputHandler.down and KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x > 1 then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x - 1
                    self.waiting_for_key_release = true
                elseif InputHandler.up then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x + 1
                    self.waiting_for_key_release = true
                elseif InputHandler.left and KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x > 10 then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x - 10
                    self.waiting_for_key_release = true
                elseif InputHandler.right then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x + 10
                    self.waiting_for_key_release = true
                end
            else
                if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                    self.waiting_for_key_release = true
                    self.setting_section_height = false
                    self.setting_section_size = false
                    self.update_layers_size = true
                    return
                elseif InputHandler.down and KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y > 1 then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y - 1
                    self.waiting_for_key_release = true
                elseif InputHandler.up then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y + 1
                    self.waiting_for_key_release = true
                elseif InputHandler.left and KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y > 10 then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y - 10
                    self.waiting_for_key_release = true
                elseif InputHandler.right then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y + 10
                    self.waiting_for_key_release = true
                end
            end
        elseif self.selecting_entity then
            if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                self.waiting_for_key_release = true
                self.entity_selected = true
                self.selecting_entity = false
                self.entity_properties_values = nil
                return
            elseif InputHandler.up and self.menu_selected > 1 then
                self.menu_selected = self.menu_selected - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.menu_selected < #KaizoEntitiesNames then
                self.menu_selected = self.menu_selected + 1
                self.waiting_for_key_release = true
            elseif InputHandler.pause then
                self.selecting_entity = false
                self.menu_selected = 1
                self.waiting_for_key_release = true
            end
        elseif self.selecting_tile then
            if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                self.waiting_for_key_release = true
                self.selecting_tile = false
                self.current_entity = nil
                return
            elseif InputHandler.down and self.current_tile > 0 then
                self.current_tile = self.current_tile - 1
                self.waiting_for_key_release = true
            elseif InputHandler.up then
                self.current_tile = self.current_tile + 1
                self.waiting_for_key_release = true
            end
        elseif self.setting_level_background then
            if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                self.waiting_for_key_release = true
                self.background_selected = true
                self.setting_level_background = false
                return
            elseif InputHandler.up and self.menu_selected > 1 then
                self.menu_selected = self.menu_selected - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.menu_selected < #self.level_background_list then
                self.menu_selected = self.menu_selected + 1
                self.waiting_for_key_release = true
            elseif InputHandler.pause then
                self.setting_level_background = false
                self.menu_selected = 1
                self.waiting_for_key_release = true
            end
        elseif self.setting_level_music then
            if InputHandler.jump or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                self.waiting_for_key_release = true
                self.music_selected = true
                self.setting_level_music = false
                return
            elseif InputHandler.up and self.menu_selected > 1 then
                self.menu_selected = self.menu_selected - 1
                self.waiting_for_key_release = true
            elseif InputHandler.down and self.menu_selected < #self.level_music_list then
                self.menu_selected = self.menu_selected + 1
                self.waiting_for_key_release = true
            elseif InputHandler.pause then
                self.setting_level_music = false
                self.menu_selected = 1
                self.waiting_for_key_release = true
            end
        elseif self.setting_level_name then
            if (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) and not (KaizoContext.CurrentLevel.Name == "init") and not (KaizoContext.CurrentLevel.Name == "") then
                self.waiting_for_key_release = true
                self.setting_level_name = false
                return
            else
                KaizoContext.CurrentLevel.Name = LoveTextInput
            end
        elseif self.editing_entity_properties then
            if InputHandler.up and self.menu_selected > 1 then
                self.menu_selected = self.menu_selected - 1
                self.waiting_for_key_release = true
                if type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "string" then
                    LoveTextInput = self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]
                end
            elseif InputHandler.down and self.menu_selected < #KaizoEntitiesCreator[self.current_entity].editor_properties then
                self.menu_selected = self.menu_selected + 1
                self.waiting_for_key_release = true
                if type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "string" then
                    LoveTextInput = self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]
                end
            elseif InputHandler.left then
                if type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "boolean" then
                    if self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] then
                        self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = false
                    else
                        self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = true
                    end
                elseif type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "number" then
                    self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] - 1
                end
                self.waiting_for_key_release = true
            elseif InputHandler.right then
                if type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "boolean" then
                    if self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] then
                        self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = false
                    else
                        self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = true
                    end
                elseif type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "number" then
                    self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] + 1
                end
                self.waiting_for_key_release = true
            elseif InputHandler.pause or (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) then
                self.editing_entity_properties = false
                self.menu_selected = 1
                self.waiting_for_key_release = true
            elseif type(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]) == "string" then
                self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]] = LoveTextInput
            end
        else
            if InputHandler.pause then
                self.menu_active = true
                self.menu_selected = 1
                self.waiting_for_key_release = true
                return
            elseif InputHandler.mouse_click then
                if self.current_entity then
                    local ent = KaizoEntitiesCreator[self.current_entity]:new(Camera.x + InputHandler.mouse_x, Camera.y + InputHandler.mouse_y)
                    
                    if ent.can_load_level_properties and self.entity_properties_values then
                        for i = 1, #ent.editor_properties, 1 do
                            ent:HandleProperty({name = ent.editor_properties[i],value = self.entity_properties_values[ent.editor_properties[i]]})
                        end
                    end

                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer]:add_entity(ent)
                    self.waiting_for_key_release = true
                elseif self.current_tile then

                    if self.current_tile > 0 and not KaizoContext.CurrentLevel:get_tile_image(self.current_tile) then
                        local image = KaizoImage:new()
                        image:load_tile_image_by_id(self.current_tile)
                        KaizoContext.CurrentLevel:add_tile_image(image)
                    end

                    local localx = math.floor((Camera.x + InputHandler.mouse_x)/32)
                    local localy = math.floor((Camera.y + InputHandler.mouse_y)/32)

                    localx = localx - math.floor(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Offset.x/32)
                    localy = localy - math.floor(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Offset.y/32)

                    if not (localx < 0 or localx >= KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Width or localy < 0 or localy >= KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Height) then
                        local val = ((KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Width) * localy + localx) + 1
                        if val > 0 and val <= #KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Tiles then
                            KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Tiles[val] = self.current_tile
                        end
                    end
                end
            elseif InputHandler.mouse_right_click then
                local pos, size
                for num, entity in ipairs(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Entities) do
                    pos = entity.pos
                    size = entity.size or {x = 1, y = 1}

                    if IsPointInsideSquare(Camera.x + InputHandler.mouse_x, Camera.y + InputHandler.mouse_y, pos.x, pos.y, size.x, size.y) then
                        entity:destroy()
                    end
                end
                KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer]:check_deleted_entities()

                local localx = math.floor((Camera.x + InputHandler.mouse_x) / 32)
                local localy = math.floor((Camera.y + InputHandler.mouse_y) / 32)

                localx = localx -
                math.floor(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers
                [self.current_layer].Offset.x / 32)
                localy = localy -
                math.floor(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers
                [self.current_layer].Offset.y / 32)

                if not (localx < 0 or localx >= KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Width or localy < 0 or localy >= KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Height) then
                    local val = ((KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Width) * localy + localx) + 1
                    if val > 0 and val <= #KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Tiles then
                        KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Tiles[val] = 0
                    end
                end
            elseif InputHandler.mouse_middle_click then
                if not self.mouse_move_pos or not self.camera_move_pos then
                    self.mouse_move_pos = {x = InputHandler.mouse_x, y = InputHandler.mouse_y}
                    self.camera_move_pos = {x = Camera.x, y = Camera.y}
                end

                Camera.x = self.camera_move_pos.x + (self.mouse_move_pos.x - InputHandler.mouse_x)
                Camera.y = self.camera_move_pos.y + (self.mouse_move_pos.y - InputHandler.mouse_y)
            elseif InputHandler.savestate then
                KaizoFileHandler:CreateDirectory("data/levels/")
                SaveStateHandler:SaveStateToFolder("data/levels", KaizoContext.CurrentLevel.Name, "kzlvl")
            elseif InputHandler.loadstate and KaizoFileHandler:FileExists("data/levels/" .. KaizoContext.CurrentLevel.Name .. ".kzlvl") then
                KaizoFileHandler:CreateDirectory("data/levels/")
                SaveStateHandler:LoadStateFrom("data/levels/" .. KaizoContext.CurrentLevel.Name .. ".kzlvl")
                if not KaizoContext.CurrentLevel.Name then
                    KaizoContext.CurrentLevel.Name = "NoNameLevel"
                end
            elseif InputHandler.up then
                Camera.y = Camera.y - 32 * 16
                self.waiting_for_key_release = true
            elseif InputHandler.down then
                Camera.y = Camera.y + 32 * 16
                self.waiting_for_key_release = true
            elseif InputHandler.left then
                Camera.x = Camera.x - 32 * 16
                self.waiting_for_key_release = true
            elseif InputHandler.right then
                Camera.x = Camera.x + 32 * 16
                self.waiting_for_key_release = true
            end
        end
    end

    if self.update_layers_size then
        local tiles = nil
        for num, layer in ipairs(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers) do
            tiles = {}

            for y = 0, KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y - 1, 1 do
                for x = 1, KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x, 1 do
                    if layer.Tiles[self.original_section_size.x * y + x] and x < self.original_section_size.x and y < self.original_section_size.y then
                        tiles[KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x * y + x] = layer.Tiles[self.original_section_size.x * y + x]
                    else
                        tiles[KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x * y + x] = 0
                    end
                end
            end

            layer:set_tiles(tiles,KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x,KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y)
            tiles = nil
        end
        self.update_layers_size = false
    end

    if self.waiting_for_key_release and not InputHandler.up and not InputHandler.down and not InputHandler.jump and not InputHandler.pause and not InputHandler.mouse_click and not InputHandler.savestate and not InputHandler.loadstate and not InputHandler.left and not InputHandler.right and not InputHandler.mouse_right_click and not (LoveKeysPressed["return"] or SDLKeysPressed[SDL.SCANCODE_RETURN]) and not InputHandler.mouse_middle_click then
        self.waiting_for_key_release = false
    end

    if not InputHandler.mouse_middle_click then
        self.mouse_move_pos = nil
        self.camera_move_pos = nil
    end

    if (not self.waiting_for_key_release) and InputHandler.pause then
        self.menu_active = false
        self.waiting_for_key_release = true
        return
    end

    if self.option_selected then
        self.menu_options[self.menu_selected].func(self)
        self.option_selected = false
        return
    elseif self.entity_selected then
        self.current_entity = KaizoEntitiesNames[self.menu_selected]
        self.entity_selected = false
        self.current_tile = nil
        return
    elseif self.background_selected then
        local img = KaizoImage:new()
        img:load("data/images/bg/"..self.level_background_list[self.menu_selected])
        KaizoContext.CurrentLevel:get_current_section().Background = nil
        KaizoContext.CurrentLevel:get_current_section().Background = img
        self.background_selected = false
    elseif self.music_selected then

        if KaizoContext.CurrentLevel:get_current_section().Music then
            KaizoContext.CurrentLevel:get_current_section().Music:Stop()
        end

        local snd = KaizoSound:new()
        snd:Load("data/music/"..self.level_music_list[self.menu_selected],true)
        KaizoContext.CurrentLevel:get_current_section().Music = nil
        KaizoContext.CurrentLevel:get_current_section().Music = snd
        self.music_selected = false
        KaizoContext.CurrentLevel:get_current_section().Music:Loop()
        KaizoContext.CurrentLevel:get_current_section().Music:Play()
    end
end

function KaizoLevelEditor:render()
    if self.warning_time > 0 then
        RenderHandler:Print2(
        "WARNING: Editor is still in development, expect crashes and bugs\nUse ESC to select a option\nPress K (Save State Key) to save level\nPress L (Load State Key) to load",
            5, 5)
        self.warning_time = self.warning_time - 1
    else
        RenderHandler:Print2(
        "Current Section: "..KaizoContext.CurrentLevel.CurrentSection.."\nCurrent Layer: "..self.current_layer,
            5, 5)
        if self.current_entity then
            RenderHandler:Print2("\n\nEntity: "..self.current_entity,
            5, 5)
        elseif self.current_tile then
            RenderHandler:Print2("\n\nTile: "..self.current_tile,
            5, 5)
        end
    end

    if self.menu_active then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            RenderHandler:Print2("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print2(self.menu_options[self.menu_selected].text, WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print2("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.selecting_entity then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            RenderHandler:Print2("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print2(KaizoEntitiesNames[self.menu_selected], WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print2("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.selecting_tile then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            RenderHandler:Print2("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print2("Tile ID: "..self.current_tile, WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print2("v", WindowSize.x / 4, WindowSize.y / 4 + 30)

            if self.prev_current_tile ~= self.current_tile then
                self.prev_current_tile = self.current_tile
                if self.current_tile > 0 and KaizoFileHandler:FileExists("data/images/tiles/tile_" .. tostring(self.current_tile) .. ".png") then
                    self.current_tile_image:load_tile_image_by_id(self.current_tile)
                end
            end

            if self.current_tile > 0 and self.current_tile_image.image and KaizoFileHandler:FileExists("data/images/tiles/tile_" .. tostring(self.current_tile) .. ".png") then
                self.current_tile_image:render_to(WindowSize.x / 4, WindowSize.y / 4 + 45)
            end
        end
    elseif self.setting_section_size then
        self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
            (WindowSize.y / 4) * 2)
        RenderHandler:Print2("           +1\n            ^", WindowSize.x / 4, WindowSize.y / 4)
        if self.setting_section_height then
            RenderHandler:Print2("-10 <- Height: "..KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y.." -> +10", WindowSize.x / 4, WindowSize.y / 4 + 30)
        else
            RenderHandler:Print2("-10 <- Width: "..KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x.." -> +10", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
        RenderHandler:Print2("           v\n             -1", WindowSize.x / 4, WindowSize.y / 4 + 45)
    elseif self.setting_level_background then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            RenderHandler:Print2("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print2(""..self.level_background_list[self.menu_selected], WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print2("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.setting_level_music then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            RenderHandler:Print2("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print2(""..self.level_music_list[self.menu_selected], WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print2("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.editing_entity_properties then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            RenderHandler:Print2("               ^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print2("Property: "..KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected].." Value: < "..tostring(self.entity_properties_values[KaizoEntitiesCreator[self.current_entity].editor_properties[self.menu_selected]]).." >", WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print2("               v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.setting_level_name then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 2,
                (WindowSize.y / 4) * 2)

            if KaizoContext.CurrentLevel.Name == "init" then
                RenderHandler:Print2("Name \"init\" is not allowed", WindowSize.x / 4, WindowSize.y / 4)
            end
                RenderHandler:Print2("Level Name: ".. KaizoContext.CurrentLevel.Name, WindowSize.x / 4, WindowSize.y / 4 + 15)
        end
    end
end

--MENU OPTIONS


function KaizoLevelEditor:new_level()
    KaizoContext.CurrentLevel = nil
    KaizoContext.CurrentLevel = KaizoLevel:new()
    KaizoContext.CurrentLevel.Name = "MyOwnLevel"
    local sec = KaizoSection:new()
    sec.Size.x = 50
    sec.Size.y = 50
    local tiles = {}
    local layer = KaizoLayer:new()
    for y = 0, sec.Size.y - 1, 1 do
        for x = 1, sec.Size.x, 1 do
            tiles[sec.Size.x * y + x] = 0
        end
    end
    layer:set_tiles(tiles,sec.Size.x,sec.Size.y)
    sec:add_layer(layer)
    KaizoContext.CurrentLevel:add_section(sec)
    KaizoContext.CurrentLevel:set_current_section(1)
    --self.current_section = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection]
end

function KaizoLevelEditor:add_section()
    local sec = KaizoSection:new()
    sec.Size.x = 50
    sec.Size.y = 50
    local tiles = {}
    local layer = KaizoLayer:new()
    for y = 0, sec.Size.y - 1, 1 do
        for x = 1, sec.Size.x, 1 do
            tiles[sec.Size.x * y + x] = 0
        end
    end
    layer:set_tiles(tiles,sec.Size.x,sec.Size.y)
    sec:add_layer(layer)
    KaizoContext.CurrentLevel:add_section(sec)
end

function KaizoLevelEditor:add_layer()
    local sec = KaizoContext.CurrentLevel:get_current_section()
    if sec then
        sec:add_layer(KaizoLayer:new())
    end
end

function KaizoLevelEditor:set_current_section()

    self.current_layer = 1
    if #KaizoContext.CurrentLevel.Sections > 0 then
        -- this way for now
        if KaizoContext.CurrentLevel.CurrentSection + 1 > #KaizoContext.CurrentLevel.Sections then
            KaizoContext.CurrentLevel:set_current_section(1)
        else
            KaizoContext.CurrentLevel:set_current_section(KaizoContext.CurrentLevel.CurrentSection + 1)
        end
    end
    --self.current_section = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection]
end

function KaizoLevelEditor:set_current_layer()
    self.current_layer = self.current_layer + 1
    if self.current_layer > #KaizoContext.CurrentLevel:get_current_section().Layers then
        self.current_layer = 1
    end
end

function KaizoLevelEditor:set_current_section_size()
    self.setting_section_size = true
    self.original_section_size = {}
    self.original_section_size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x
    self.original_section_size.y = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y
end

function KaizoLevelEditor:select_entity()
    self.selecting_entity = true
end

function KaizoLevelEditor:select_tile()
    self.selecting_tile = true
    self.current_tile = 0
end

function KaizoLevelEditor:edit_entity_properties()
    if not self.current_entity then
        return
    end

    self.editing_entity_properties = true
    self.menu_selected = 1

    if not self.entity_properties_values then
        self.entity_properties_values = {}

        local tempent = KaizoEntitiesCreator[self.current_entity]:new() -- to generate default values
        for index, name in ipairs(KaizoEntitiesCreator[self.current_entity].editor_properties) do
            self.entity_properties_values[name] = tempent[name]
            if index == 1 and type(self.entity_properties_values[name]) == "string" then
                LoveTextInput = self.entity_properties_values[name] -- default text if first property is string
            end
        end
    end
end

function KaizoLevelEditor:close_editor()
    KaizoContext.LevelEditor = false
    KaizoLevelHandler:LoadLevelFromName("init")
end

function KaizoLevelEditor:reset_camera()
    Camera.x = 0
    Camera.y = 0
end

function KaizoLevelEditor:set_background()
    self.setting_level_background = true
    self.menu_selected = 1

    self.level_background_list = KaizoFileHandler:GetItemsInDirectory("data/images/bg/")
end

function KaizoLevelEditor:set_music()
    self.setting_level_music = true
    self.menu_selected = 1

    self.level_music_list = KaizoFileHandler:GetItemsInDirectory("data/music/")
end

function KaizoLevelEditor:set_level_name()
    self.setting_level_name = true
    LoveTextInput = KaizoContext.CurrentLevel.Name
end
