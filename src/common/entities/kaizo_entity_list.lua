--[[
    PLUSKAIZO
    Copyright (c) Benjamín Gajardo All rights reserved

    You are not allowed to use or read this code without my explicit permission
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
require("common.entities.squares.kaizo_square_resize")
require("common.entities.squares.kaizo_finish")
require("common.entities.objects.kaizo_camera_follow")
require("common.entities.squares.kaizo_death_effect")
require("common.entities.squares.kaizo_door")
require("common.entities.squares.kaizo_coco")
require("common.entities.squares.kaizo_sign")
require("common.entities.squares.kaizo_shooter_ball")
require("common.entities.squares.kaizo_bouncy_bean")


KaizoEntitiesCreator = {} --to register entities
KaizoEntitiesNames = {} --to register entities in editor

--[[

KaizoEntitiesCreator[ENTITY.name] = ENTITY --for load
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = ENTITY.name --to use in level editor

Commented values are not intended for use in editor

]]

KaizoEntitiesCreator[KaizoSquare.name] = KaizoSquare
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoSquare.name
KaizoEntitiesCreator[KaizoPlayer.name] = KaizoPlayer
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoPlayer.name
KaizoEntitiesCreator[KaizoEGG.name] = KaizoEGG
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoEGG.name
KaizoEntitiesCreator[KaizoLogo.name] = KaizoLogo
--KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoLogo.name
KaizoEntitiesCreator[KaizoTomate.name] = KaizoTomate
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoTomate.name
KaizoEntitiesCreator[KaizoMushroom.name] = KaizoMushroom
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoMushroom.name
KaizoEntitiesCreator[KaizoChicken.name] = KaizoChicken
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoChicken.name
KaizoEntitiesCreator[KaizoFallingEGG.name] = KaizoFallingEGG
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoFallingEGG.name
KaizoEntitiesCreator[KaizoNest.name] = KaizoNest
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoNest.name
KaizoEntitiesCreator[KaizoMenuItem.name] = KaizoMenuItem
--KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoMenuItem.name
KaizoEntitiesCreator[KaizoDirtMonster.name] = KaizoDirtMonster
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoDirtMonster.name
KaizoEntitiesCreator[KaizoGlass.name] = KaizoGlass
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoGlass.name
KaizoEntitiesCreator[KaizoSquareResize.name] = KaizoSquareResize
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoSquareResize.name
KaizoEntitiesCreator[KaizoFinish.name] = KaizoFinish
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoFinish.name
KaizoEntitiesCreator[KaizoCameraFollow.name] = KaizoCameraFollow
--KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoCameraFollow.name
KaizoEntitiesCreator[KaizoDeathEffect.name] = KaizoDeathEffect
--KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoDeathEffect.name
KaizoEntitiesCreator[KaizoDoor.name] = KaizoDoor
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoDoor.name
KaizoEntitiesCreator[KaizoCoco.name] = KaizoCoco
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoCoco.name 
KaizoEntitiesCreator[KaizoSign.name] = KaizoSign
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoSign.name
KaizoEntitiesCreator[KaizoShooterBall.name] = KaizoShooterBall
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoShooterBall.name
KaizoEntitiesCreator[KaizoBouncyBean.name] = KaizoBouncyBean
KaizoEntitiesNames[#KaizoEntitiesNames + 1] = KaizoBouncyBean.name
