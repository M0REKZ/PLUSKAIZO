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

require("common.entities.kaizo_square")
require("common.entities.squares.kaizo_player")
require("common.entities.squares.kaizo_egg")
require("common.entities.objects.kaizo_logo")
require("common.entities.squares.kaizo_tomate")
require("common.entities.squares.kaizo_mushroom")
require("common.entities.squares.kaizo_chicken")
require("common.entities.squares.kaizo_falling_egg")
require("common.entities.squares.kaizo_nest")
require("common.entities.objects.kaizo_menu_item")
require("common.entities.squares.kaizo_dirt_monster")
require("common.entities.squares.kaizo_glass")


KaizoEntitiesCreator = {} --to register entities

KaizoEntitiesCreator[KaizoSquare.name] = KaizoSquare
KaizoEntitiesCreator[KaizoPlayer.name] = KaizoPlayer
KaizoEntitiesCreator[KaizoEGG.name] = KaizoEGG
KaizoEntitiesCreator[KaizoLogo.name] = KaizoLogo
KaizoEntitiesCreator[KaizoTomate.name] = KaizoTomate
KaizoEntitiesCreator[KaizoMushroom.name] = KaizoMushroom
KaizoEntitiesCreator[KaizoChicken.name] = KaizoChicken
KaizoEntitiesCreator[KaizoFallingEGG.name] = KaizoFallingEGG
KaizoEntitiesCreator[KaizoNest.name] = KaizoNest
KaizoEntitiesCreator[KaizoMenuItem.name] = KaizoMenuItem
KaizoEntitiesCreator[KaizoDirtMonster.name] = KaizoDirtMonster
KaizoEntitiesCreator[KaizoGlass.name] = KaizoGlass
