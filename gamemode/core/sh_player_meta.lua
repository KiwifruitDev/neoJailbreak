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
function pmeta:CanPickupWeapon(entity)
    if table.Count(self:GetWeapons()) > 0 then
        for _, v in pairs(self:GetWeapons()) do
            if v.Slot == entity.Slot or v:GetClass() == entity:GetClass() then return false end
        end
    end
    return true
end

function pmeta:GetWarden()
    return JB:GetWarden() == self
end
