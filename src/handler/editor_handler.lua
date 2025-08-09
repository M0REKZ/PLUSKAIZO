KaizoLevelEditor = {}

function KaizoLevelEditor:init()
    self.menu_active = false
    self.menu_selected = 1
    self.menu_options = {}

    self.selecting_entity = false
    self.selecting_tile = false

    self.setting_section_size = false
    self.setting_section_height = false

    self.update_layers_size = false

    self.number_input = 0

    self.warning_time = 500

    for i = 1, 10, 1 do
        self.menu_options[i] = {}
    end

    self.menu_options[1].text = "New Level"
    self.menu_options[1].func = KaizoLevelEditor.new_level
    self.menu_options[2].text = "Select Entity"
    self.menu_options[2].func = KaizoLevelEditor.select_entity
    self.menu_options[3].text = "Select Tile"
    self.menu_options[3].func = KaizoLevelEditor.select_tile
    self.menu_options[4].text = "Edit Entity Properties"
    self.menu_options[4].func = KaizoLevelEditor.edit_entity_properties
    self.menu_options[5].text = "Add Section"
    self.menu_options[5].func = KaizoLevelEditor.add_section
    self.menu_options[6].text = "Add Layer to Section"
    self.menu_options[6].func = KaizoLevelEditor.add_layer
    self.menu_options[7].text = "Set Current Section"
    self.menu_options[7].func = KaizoLevelEditor.set_current_section
    self.menu_options[8].text = "Set Current Layer"
    self.menu_options[8].func = KaizoLevelEditor.set_current_layer
    self.menu_options[9].text = "Set Section Size"
    self.menu_options[9].func = KaizoLevelEditor.set_current_section_size
    self.menu_options[10].text = "Close Level Editor"
    self.menu_options[10].func = KaizoLevelEditor.close_editor

    self.waiting_for_key_release = false
    self.option_selected = false
    self.entity_selected = false

    self.background = KaizoImage:new()
    self.background:load("data/images/blacksquare.png")

    self.current_layer = 1
    self.current_section = nil

    self.current_tile = nil
    self.current_entity = nil
end

function KaizoLevelEditor:update()
    if not self.waiting_for_key_release then
        if self.menu_active then
            if InputHandler.jump then
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
                if InputHandler.jump then
                    self.waiting_for_key_release = true
                    self.setting_section_height = true
                    return
                elseif InputHandler.down and KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x > 1 then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x - 1
                    self.waiting_for_key_release = true
                elseif InputHandler.up then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x + 1
                    self.waiting_for_key_release = true
                end
            else
                if InputHandler.jump then
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
                end
            end
        elseif self.selecting_entity then
            if InputHandler.jump then
                self.waiting_for_key_release = true
                self.entity_selected = true
                self.selecting_entity = false
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
            if InputHandler.jump then
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
        else
            if InputHandler.pause then
                self.menu_active = true
                self.menu_selected = 1
                self.waiting_for_key_release = true
                return
            elseif InputHandler.mouse_click then
                if self.current_entity then
                    KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer]:add_entity(KaizoEntitiesCreator[self.current_entity]:new(
                    Camera.x + InputHandler.mouse_x, Camera.y + InputHandler.mouse_y))
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

                    local val = ((KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Width) * localy + localx) + 1
                    print(self.current_layer)
                    if val > 0 and val <= #KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Tiles then
                        KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers[self.current_layer].Tiles[val] = self.current_tile
                    end
                end
                
            elseif InputHandler.savestate then
                SaveStateHandler:SaveStateToFolder("data/levels", "MyOwnLevel", "kzlvl")
            elseif InputHandler.loadstate then
                SaveStateHandler:LoadStateFrom("data/levels/" .. "MyOwnLevel" .. ".kzlvl")
            elseif InputHandler.up then
                Camera.y = Camera.y - 32
                self.waiting_for_key_release = true
            elseif InputHandler.down then
                Camera.y = Camera.y + 32
                self.waiting_for_key_release = true
            elseif InputHandler.left then
                Camera.x = Camera.x - 32
                self.waiting_for_key_release = true
            elseif InputHandler.right then
                Camera.x = Camera.x + 32
                self.waiting_for_key_release = true
            end
        end
    end

    if self.update_layers_size then
        local tiles = {}
        for num, layer in ipairs(KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Layers) do
            for i = 1, KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x * KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y, 1 do
                tiles[i] = 0
            end

            layer:set_tiles(tiles,KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x,KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y)
        end
        self.update_layers_size = false
    end

    if self.waiting_for_key_release and not InputHandler.up and not InputHandler.down and not InputHandler.jump and not InputHandler.pause and not InputHandler.mouse_click and not InputHandler.savestate and not InputHandler.loadstate and not InputHandler.left and not InputHandler.right then
        self.waiting_for_key_release = false
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
    end
end

function KaizoLevelEditor:render()
    if self.warning_time > 0 then
        RenderHandler:Print(
        "WARNING: Editor is still in development, expect crashes and bugs\nUse ESC to select a option\nPress K (Save State Key) to save level\nPress L (Load State Key) to load",
            5, 5)
        self.warning_time = self.warning_time - 1
    end

    if self.menu_active then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 3,
                (WindowSize.y / 4) * 3)

            RenderHandler:Print("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print(self.menu_options[self.menu_selected].text, WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.selecting_entity then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 3,
                (WindowSize.y / 4) * 3)

            RenderHandler:Print("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print(KaizoEntitiesNames[self.menu_selected], WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.selecting_tile then
        if self.background then
            self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 3,
                (WindowSize.y / 4) * 3)

            RenderHandler:Print("^", WindowSize.x / 4, WindowSize.y / 4)
            RenderHandler:Print("Tile ID: "..self.current_tile, WindowSize.x / 4, WindowSize.y / 4 + 15)
            RenderHandler:Print("v", WindowSize.x / 4, WindowSize.y / 4 + 30)
        end
    elseif self.setting_section_size then
        self.background:render_scaled_to(WindowSize.x / 4, WindowSize.y / 4, (WindowSize.x / 4) * 3,
            (WindowSize.y / 4) * 3)
        RenderHandler:Print("+", WindowSize.x / 4, WindowSize.y / 4)
        if self.setting_section_height then
            RenderHandler:Print("Height: "..KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.y, WindowSize.x / 4, WindowSize.y / 4 + 15)
        else
            RenderHandler:Print("Width: "..KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection].Size.x, WindowSize.x / 4, WindowSize.y / 4 + 15)
        end
        RenderHandler:Print("-", WindowSize.x / 4, WindowSize.y / 4 + 30)
    end
end

--MENU OPTIONS


function KaizoLevelEditor:new_level()
    KaizoContext.CurrentLevel = nil
    KaizoContext.CurrentLevel = KaizoLevel:new()
    local sec = KaizoSection:new()
    sec:add_layer(KaizoLayer:new())
    KaizoContext.CurrentLevel:add_section(sec)
    KaizoContext.CurrentLevel:set_current_section(1)
    --self.current_section = KaizoContext.CurrentLevel.Sections[KaizoContext.CurrentLevel.CurrentSection]
end

function KaizoLevelEditor:add_section()
    KaizoContext.CurrentLevel:add_section(KaizoSection:new())
end

function KaizoLevelEditor:add_layer()
    local sec = KaizoContext.CurrentLevel:get_current_section()
    if sec then
        sec:add_layer(KaizoLayer:new())
    end
end

function KaizoLevelEditor:set_current_section()
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
    
end

function KaizoLevelEditor:set_current_section_size()
    self.setting_section_size = true
end

function KaizoLevelEditor:select_entity()
    self.selecting_entity = true
end

function KaizoLevelEditor:select_tile()
    self.selecting_tile = true
    self.current_tile = 0
end

function KaizoLevelEditor:edit_entity_properties()
    
end

function KaizoLevelEditor:close_editor()
    KaizoContext.LevelEditor = false
    KaizoLevelHandler:LoadLevelFromName("init")
end
