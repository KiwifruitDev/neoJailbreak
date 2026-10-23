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
PLAYER.DisplayName = "Prisoner"
PLAYER.WalkSpeed = 260
PLAYER.RunSpeed = 310
PLAYER.CrouchedWalkSpeed = 0.4
PLAYER.DuckSpeed = 0.3
PLAYER.UnDuckSpeed = 0.3
PLAYER.JumpPower = 200
PLAYER.CanUseFlashlight = false
PLAYER.MaxHealth = 100
PLAYER.StartHealth = 100
PLAYER.StartArmor = 50
PLAYER.DropWeaponOnDie = false
PLAYER.AvoidPlayers = false
function PLAYER:Spawn()
    self.Player:SetPlayerColor(Vector(.9, .9, .9))
    self.Player:SetWeaponColor(Vector(.9, .9, .9))
    self.Player:SetRebel(false)
    self.Player:GiveAmmo(50, "Pistol", true)
    self.Player:GiveAmmo(100, "SMG1", true)
end

local randomSpecialWeapon = {"weapon_jb_knife"}
function PLAYER:Loadout()
    self.Player:Give("weapon_jb_fists")
    if math.random(1, JB.Config.prisonerSpecialChance) == 1 then
        self.Player:Give(table.Random(randomSpecialWeapon)) -- give the player a rando waeapon from our table.
    end
end

function PLAYER:SetupDataTables()
    self.Player:NetworkVar("Bool", 0, "Rebel")
    --self.Player:NetworkVar("Bool", 1, "InGuardZone")
end

local prisonerModels = {Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_03.mdl"), Model("models/player/Group01/female_05.mdl"), Model("models/player/Group01/male_01.mdl"), Model("models/player/Group01/male_03.mdl"), Model("models/player/Group01/female_02.mdl"), Model("models/player/Group01/female_01.mdl"), Model("models/player/Group01/female_04.mdl"), Model("models/player/Group01/female_06.mdl"), Model("models/player/Group01/male_02.mdl"), Model("models/player/Group01/male_04.mdl"), Model("models/player/Group01/male_05.mdl"), Model("models/player/Group01/male_06.mdl"), Model("models/player/Group01/male_07.mdl"), Model("models/player/Group01/male_08.mdl"), Model("models/player/Group01/male_09.mdl")}
function PLAYER:SetModel()
    if self.Player._prisonermodel then --after a rejoin or a map change/server restart, players need to re-equip the pointshop playermodel.
        self.Player:SetModel(self.Player._prisonermodel)
    else
        self.Player:SetModel(string.lower(table.Random(prisonerModels)))
    end
end

player_manager.RegisterClass("player_prisoner", PLAYER, "player_default")
