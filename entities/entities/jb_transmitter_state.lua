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
ENT.Base = "base_point"
ENT.Type = "point"
ENT.PrintName = "JB State Transmitter"
function ENT:Initialize()
    JB.TRANSMITTER = self
    JB:DebugPrint("Setup State Transmitter!")
    --self:SetPredictable(true)
end

function ENT:Think()
    if not IsValid(JB.TRANSMITTER) and IsValid(self) then --there is no registered transmitter and yet we're here. What's going on? Let's assume that we are the transmitter that is being looked for.
        JB.TRANSMITTER = self
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "JBState")
    self:NetworkVar("Int", 1, "JBRoundsPassed")
    self:NetworkVar("Vector", 0, "JBWarden_PointerPos")
    self:NetworkVar("String", 0, "JBLastRequestPicked")
    self:NetworkVar("String", 1, "JBWarden_PointerType")
    self:NetworkVar("String", 2, "JBScriptday")
    self:NetworkVar("Float", 0, "JBRoundStartTime")
    self:NetworkVar("Entity", 0, "JBLastRequestPrisoner")
    self:NetworkVar("Entity", 1, "JBLastRequestGuard")
    self:NetworkVar("Entity", 2, "JBWarden")
    self:NetworkVar("Bool", 0, "JBWarden_PVPDamage")
    self:NetworkVar("Bool", 1, "JBWarden_ItemPickup")
    self:NetworkVar("Bool", 2, "JBWarden_GuardDamage")
    if SERVER then
        self:SetJBRoundStartTime(0)
        self:SetJBState(STATE_IDLE)
        self:SetJBScriptday("")
        self:SetJBRoundsPassed(0)
        self:SetJBWarden_PointerType("0")
        self:SetJBWarden_PointerPos(Vector(0, 0, 0))
        self:SetJBWarden_PVPDamage(false)
        self:SetJBWarden_ItemPickup(false)
        self:SetJBWarden_GuardDamage(false)
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:KeyValue(key, value)
    if self:SetNetworkKeyValue(key, value) then return end
end

function ENT:CanEditVariables()
    return false
end
