--[[
    neoJailbreak
    Copyright (c) 2026 KiwifruitDev
    https://github.com/KiwifruitDev/neoJailbreak
    
    Jailbreak 7
    Copyright (c) 2014 Casual Bananas
    https://github.com/casualbananas/jailbreak-game

    This gamemode is derived from the original Jailbreak 7.
    See LICENSE for copyright attribution and licensing information.
]]--

DEFINE_BASECLASS("player_default")
local PLAYER = {}
PLAYER.DisplayName = "Spectator"
PLAYER.WalkSpeed = 260
PLAYER.RunSpeed = 260
PLAYER.DuckSpeed = 1
player_manager.RegisterClass("player_spectator", PLAYER, "player_default")
