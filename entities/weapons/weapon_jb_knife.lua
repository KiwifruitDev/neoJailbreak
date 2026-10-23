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
local sound_single = Sound("weapons/knife/knife_slash1.wav")
function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    if not IsValid(self:GetOwner()) then return end
    if self:GetOwner().LagCompensation and SERVER then self:GetOwner():LagCompensation(true) end
    --self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_MISSCENTER)
    local spos = self:GetOwner():GetShootPos()
    local sdest = spos + self:GetOwner():GetAimVector() * 70
    local tr_main = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
        filter = self:GetOwner()
   })

    if not IsValid(tr_main.Entity) then
        tr_main = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
            filter = self:GetOwner(),
            mins = Vector(-15, -15, -8),
            maxs = Vector(15, 15, 8)
       })
    end

    local hitEnt = tr_main.Entity
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_HITCENTER)
    if IsValid(hitEnt) then
        self:EmitSound(sound_single)
        if SERVER and IsFirstTimePredicted() then
            local edata = EffectData()
            edata:SetStart(spos)
            edata:SetOrigin(tr_main.HitPos)
            edata:SetNormal(tr_main.Normal)
            edata:SetEntity(hitEnt)
            if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
                timer.Simple(0.05, function() self:EmitSound("weapons/knife/knife_hit1.wav") end)
                util.Effect("BloodImpact", edata)
                self:GetOwner():FireBullets({
                    Num = 1,
                    Src = spos,
                    Dir = self:GetOwner():GetAimVector(),
                    Spread = Vector(0, 0, 0),
                    Tracer = 0,
                    Force = 1,
                    Damage = 0
               })
            else
                timer.Simple(0.05, function() self:EmitSound("weapons/knife/knife_hitwall1.wav") end)
                util.Effect("Impact", edata)
            end
        end
    elseif tr_main.HitWorld then
        self:EmitSound(sound_single)
        timer.Simple(0.05, function() self:EmitSound("weapons/knife/knife_hitwall1.wav") end)
        if SERVER and IsFirstTimePredicted() then
            local edata = EffectData()
            edata:SetStart(spos)
            edata:SetOrigin(tr_main.HitPos)
            edata:SetNormal(tr_main.Normal)
            edata:SetEntity(hitEnt)
            if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
                util.Effect("BloodImpact", edata)
                self:GetOwner():FireBullets({
                    Num = 1,
                    Src = spos,
                    Dir = self:GetOwner():GetAimVector(),
                    Spread = Vector(0, 0, 0),
                    Tracer = 0,
                    Force = 1,
                    Damage = 0
               })
            else
                util.Effect("Impact", edata)
            end
        end
    else
        self:EmitSound(sound_single)
    end

    if SERVER and hitEnt and hitEnt:IsValid() then
        local dmg = DamageInfo()
        dmg:SetDamage(self.Primary.Damage)
        dmg:SetAttacker(self:GetOwner())
        dmg:SetInflictor(self)
        dmg:SetDamageForce(self:GetOwner():GetAimVector() * 1500)
        dmg:SetDamagePosition(self:GetOwner():GetPos())
        dmg:SetDamageType(DMG_CLUB)
        hitEnt:DispatchTraceAttack(dmg, spos + self:GetOwner():GetAimVector() * 3, sdest)
    end

    if self:GetOwner().LagCompensation and SERVER then self:GetOwner():LagCompensation(false) end
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
