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

local LR = JB.CLASS_LR()
LR:SetName("Knife Battle")
LR:SetDescription("The guard and the prisoner both get a knife, all other weapons are stripped, and they must fight eachother until one of the two dies")
LR:SetStartCallback(function(prisoner, guard)
    for _, ply in ipairs{prisoner, guard} do
        ply:StripWeapons()
        ply:Give("weapon_jb_knife")
        ply:Give("weapon_jb_fists")
        ply:SetHealth(100)
        ply:SetArmor(0)
    end
end)

LR:SetIcon(Material("icon16/flag_blue.png"))
LR()
