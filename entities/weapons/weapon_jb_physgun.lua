-- this weapon is a facade and selecting it will select the real physgun
AddCSLuaFile()
SWEP.PrintName = "Physics Gun"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.Category = "Jailbreak Weapons"
function SWEP:Deploy()
    self:GetOwner():Give("weapon_physgun")
    self:GetOwner():SelectWeapon("weapon_physgun")
end
