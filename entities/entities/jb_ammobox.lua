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

AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Items/item_item_crate.mdl")
        self:SetUseType(SIMPLE_USE)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end
end

function ENT:Use(p)
    if IsValid(p) and (not p.nextAmmoCrate or p.nextAmmoCrate < CurTime()) then
        p.nextAmmoCrate = CurTime() + 5
        p:GiveAmmo(128, "SMG1")
        p:GiveAmmo(128, "Pistol")
        p:SendNotification("You picked up an ammo crate")
        self:Remove()
    elseif IsValid(p) then
        p:SendQuickNotification("You already picked up an ammo crate!")
    end
end

function ENT:Draw()
    self:DrawModel()
end
