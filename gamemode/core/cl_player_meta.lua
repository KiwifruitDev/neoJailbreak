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

local pmeta = FindMetaTable("Player")
local uniqueid
local getname = pmeta.Nick
function pmeta:Nick()
    if tobool(JB.Config.prisonerNameChange) and LocalPlayer():Alive() and self:Alive() and self:Team() == TEAM_PRISONER then
        uniqueid = self:UniqueID()
        return (LocalPlayer():IsAdmin() and "[" .. getname(self) .. "] " or "Prisoner ") .. string.Right(uniqueid, string.len(uniqueid) / 2)
    end
    return getname(self)
end
