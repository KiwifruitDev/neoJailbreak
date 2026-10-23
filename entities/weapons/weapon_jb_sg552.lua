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
SWEP.PrintName = "SG552"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_jb_base"
SWEP.Category = "Jailbreak Weapons"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_sg552.mdl"
SWEP.WorldModel = "models/weapons/w_rif_sg552.mdl"
SWEP.Primary.Sound = Sound("Weapon_SG552.Single")
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Damage = 28
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 30
SWEP.Primary.Delay = 0.10
SWEP.Primary.DefaultClip = 90
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Positions = {}
SWEP.Positions[1] = {
    pos = Vector(0, 0, 0),
    ang = Vector(0, 0, 0)
}

SWEP.Positions[2] = {
    pos = Vector(-7.04, -12.205, 3.599),
    ang = Vector(0.5, 1.899, 0)
}

SWEP.Positions[3] = {
    pos = Vector(7.322, -20, 0),
    ang = Vector(0, 70, 0)
}
