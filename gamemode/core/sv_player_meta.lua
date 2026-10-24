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

local function setPlayerTeamColor(ply, teamID)
    local color
    if teamID == TEAM_GUARD then
        color = Vector(0, 0, 1)
    elseif teamID == TEAM_PRISONER and ply.GetRebel and ply:GetRebel() then
        color = Vector(1, 0, 0)
    else
        color = Vector(1, 1, 1)
    end

    ply:SetPlayerColor(color)
    ply:SetWeaponColor(color)
end
-- PLAYER CLASS SETTING
local oldSetTeam = pmeta.SetTeam
function pmeta:SetTeam(tm)
    player_manager.SetPlayerClass(self, tm == TEAM_GUARD and "player_guard" or tm == TEAM_PRISONER and "player_prisoner" or "player_spectator")
    oldSetTeam(self, tm)
    setPlayerTeamColor(self, tm)
end

hook.Add("PlayerSpawn", "JB.PlayerSpawn.SetTeamColor", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then setPlayerTeamColor(ply, ply:Team()) end
    end)
end)

-- PRISONER STATUS
function pmeta:AddRebelStatus()
    if self:Team() ~= TEAM_PRISONER or not self:Alive() then return end
    self:SetRebel(true)
    JB:BroadcastNotification(self:Nick() .. " is rebelling!")
    setPlayerTeamColor(self, TEAM_PRISONER)
end

function pmeta:RemoveRebelStatus()
    if not self.SetRebel then return end
    self:SetRebel(false)
    setPlayerTeamColor(self, TEAM_PRISONER)
end

-- WARDEN STATUS
function pmeta:AddWardenStatus()
    if self:Team() ~= TEAM_GUARD or not self:Alive() or not IsValid(JB.TRANSMITTER) then return end
    --self:SetModel("models/player/barney.mdl")
    self:SetArmor(100)
    JB.TRANSMITTER:SetJBWarden(self)
end

function pmeta:RemoveWardenStatus()
    if not self:Alive() and IsValid(JB.TRANSMITTER) then return end
    self:SetModel("models/player/police.mdl")
    JB.TRANSMITTER:SetJBWarden(NULL)
end

function pmeta:SetupHands(ply)
    if IsValid(ply) and ply ~= self then -- we don't need in-eye spectator.
        return
    end

    local oldhands = self:GetHands()
    if IsValid(oldhands) then oldhands:Remove() end
    local hands = ents.Create("gmod_hands")
    if IsValid(hands) then
        hands:DoSetup(self, ply)
        hands:Spawn()
    end
end

-- NOTIFICATIONS
util.AddNetworkString("JB.SendNotification")
function pmeta:SendNotification(text)
    net.Start("JB.SendNotification")
    net.WriteString(text)
    net.Send(self)
end

util.AddNetworkString("JB.SendQuickNotification")
function pmeta:SendQuickNotification(msg)
    net.Start("JB.SendQuickNotification")
    net.WriteString(msg)
    net.Send(self)
end
