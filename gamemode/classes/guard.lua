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
PLAYER.DisplayName = "Guard"
PLAYER.WalkSpeed = 260
PLAYER.RunSpeed = 325
PLAYER.CrouchedWalkSpeed = 0.4
PLAYER.DuckSpeed = 0.3
PLAYER.UnDuckSpeed = 0.3
PLAYER.JumpPower = 200
PLAYER.CanUseFlashlight = true
PLAYER.MaxHealth = 100
PLAYER.StartHealth = 100
PLAYER.StartArmor = 50
PLAYER.DropWeaponOnDie = true
PLAYER.AvoidPlayers = false
function PLAYER:Spawn()
    self.Player:SetPlayerColor(Vector(0, 0, 1))
    self.Player:SetWeaponColor(Vector(0, 0, 1))
end

--local randomGuardSidearms = {"weapon_jb_deagle", "weapon_jb_usp", "weapon_jb_fiveseven"}
--local randomGuardPrimary = {"weapon_jb_ak47", "weapon_jb_aug", "weapon_jb_galil", "weapon_jb_m4a1", "weapon_jb_mac10", "weapon_jb_mp5navy", "weapon_jb_p90", "weapon_jb_scout", "weapon_jb_sg552", "weapon_jb_ump"}
function PLAYER:Loadout()
    local grapple = ents.Create("sent_grapplehook_bpack")
    grapple:SetSlotName("sent_grapplehook_bpack")
    grapple:Spawn()
    grapple:SetKey(36)
    if not grapple:Attach(self.Player, true) then
        grapple:Remove()
        return
    end

    self.Player:Give("weapon_jb_fists")
    if self.Player.GetNWString("guardweapon") then
        self.Player:Give(self.Player.GetNWString("guardweapon"))
        self.Player:GiveAmmo(self.Player.GetNWInt("guardammo"), self.Player.GetNWString("guardammotype"), true)
    end

    --self.Player:Give(table.Random(randomGuardSidearms))
    --self.Player:Give(table.Random(randomGuardPrimary))
    self.Player:GiveAmmo(255, "Pistol", true)
    self.Player:GiveAmmo(512, "SMG1", true)
end

function PLAYER:SetupDataTables()
    --self.Player:NetworkVar("Bool", 1, "InGuardZone")
end

util.PrecacheModel("models/player/police.mdl")
function PLAYER:SetModel()
    if self.Player._guardmodel then --after a rejoin or a map change/server restart, players need to re-equip the pointshop playermodel.
        self.Player:SetModel(self.Player._guardmodel)
    else
        self.Player:SetModel("models/player/police.mdl")
    end
end

player_manager.RegisterClass("player_guard", PLAYER, "player_default")
