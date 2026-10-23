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

hook.Add("OnEntityCreated", "JB.OnEntityCreated.InvalidateDefaultWeapons", function(entity)
    if string.lower(string.Left(entity:GetClass(), 6)) == "weapon" or entity:IsWeapon() then
        timer.Simple(0, function()
            if not IsValid(entity) then return end
            entity.IsDropped = true
            entity.BeingPickedUp = false
            local object = entity:GetPhysicsObject()
            if object and IsValid(object) then
                object:EnableGravity(true)
                object:EnableMotion(true)
                object:Wake()
            end
        end)
    end
end)
