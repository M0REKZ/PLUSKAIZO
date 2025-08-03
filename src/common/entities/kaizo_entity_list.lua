-- PLUSKAIZO (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the PLUSKAIZO directory for license

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
