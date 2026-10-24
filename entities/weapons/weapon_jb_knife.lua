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
if SERVER then
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
end

if CLIENT then
    SWEP.DrawCrosshair = false
    SWEP.ViewModelFlip = false
    SWEP.DrawWeaponInfoBox = false
    SWEP.ViewModelFOV = 54
end

SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.Author = "Excl"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.PrintName = "Knife"
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.Primary.Damage = 25
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 5
SWEP.HoldType = "knife"
SWEP.HitDistance = 50
SWEP.HitDelay = 0.07
local sound_single = Sound("weapons/knife/knife_slash1.wav")
local sound_hit = Sound("weapons/knife/knife_hit1.wav")
local sound_hit_wall = Sound("weapons/knife/knife_hitwall1.wav")
function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_MISSCENTER)
    if SERVER then
        owner:EmitSound(sound_single)

        timer.Simple(self.HitDelay, function()
            if not IsValid(self) or not IsValid(owner) then return end

            local startPos = owner:GetShootPos()
            local aimVector = owner:GetAimVector()
            local endPos = startPos + aimVector * self.HitDistance
            if owner:IsPlayer() then owner:LagCompensation(true) end
            local trace = util.TraceLine({
                start = startPos,
                endpos = endPos,
                filter = owner
           })
            if owner:IsPlayer() then owner:LagCompensation(false) end
            if not trace.Hit then return end

            local hitEnt = trace.Entity
            local isFlesh = IsValid(hitEnt) and (hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:GetClass() == "prop_ragdoll")
            self:EmitSound(isFlesh and sound_hit or sound_hit_wall)

            local effectData = EffectData()
            effectData:SetStart(startPos)
            effectData:SetOrigin(trace.HitPos)
            effectData:SetNormal(trace.HitNormal)
            effectData:SetSurfaceProp(trace.SurfaceProps)
            effectData:SetHitBox(trace.HitBox)
            effectData:SetDamageType(DMG_SLASH)
            if IsValid(hitEnt) then effectData:SetEntity(hitEnt) end
            if isFlesh and not hitEnt:IsPlayer() and not hitEnt:IsNPC() then
                util.Effect("BloodImpact", effectData, true, true)
            elseif not isFlesh then
                util.Effect("StunstickImpact", effectData, true, true)
            end
            local decal = isFlesh and "Blood" or "ManhackCut"
            util.Decal(decal, trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)

            if IsValid(hitEnt) and not trace.HitWorld and (hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:Health() > 0) then
                local dmg = DamageInfo()
                dmg:SetDamage(self.Primary.Damage)
                dmg:SetAttacker(owner)
                dmg:SetInflictor(self)
                dmg:SetDamageForce(aimVector * 1500)
                dmg:SetDamagePosition(trace.HitPos)
                dmg:SetDamageType(DMG_SLASH)
                hitEnt:DispatchTraceAttack(dmg, trace, aimVector)
            end
        end)
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:GetClass()
    return "jb_knife"
end

function SWEP:OnDrop()
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
    draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
    -- Draw a CS:S select icon
    self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
    -- Print weapon information
end
