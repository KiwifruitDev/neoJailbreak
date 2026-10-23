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

-- NOTE: Loosely based on the default Garry's Mod hands.
AddCSLuaFile()
SWEP.PrintName = "Fists"
SWEP.UseHands = false
SWEP.Author = "Excl"
SWEP.Purpose = ""
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 52
SWEP.Slot = 0
SWEP.SlotPos = 5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
local SwingSound = Sound("weapons/slam/throw.wav")
local HitSound = Sound("Flesh.ImpactHard")
function SWEP:PreDrawViewModel()
    if not self:GetRaised() then
        self.Correct = true
        render.SetBlend(0)
    else
        self.Corrent = false
    end
end

function SWEP:PostDrawViewModel()
    if self.Corrent then
        render.SetBlend(1)
        self.Correct = false
    end
end

SWEP.HitDistance = 48
function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextMeleeAttack")
    self:NetworkVar("Float", 1, "NextIdle")
    self:NetworkVar("Int", 0, "Combo")
    self:NetworkVar("Bool", 0, "Raised")
end

function SWEP:UpdateNextIdle()
    local vm = self:GetOwner():GetViewModel()
    self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

function SWEP:PrimaryAttack(right)
    if not self:GetRaised() then
        if CLIENT and IsFirstTimePredicted() and not self:GetOwner().DoNotNotify then
            notification.AddLegacy("Press R to raise your fists", NOTIFY_HINT)
            self:SetNextPrimaryFire(CurTime() + 1.8)
            self:SetNextSecondaryFire(CurTime() + 1.8)
            self:GetOwner().DoNotNotify = true
        end
        return
    end

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    local anim = "fists_left"
    if right then anim = "fists_right" end
    if self:GetCombo() >= 2 then anim = "fists_uppercut" end
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
    self:EmitSound(SwingSound)
    self:UpdateNextIdle()
    self:SetNextMeleeAttack(CurTime() + 0.2)
    self:SetNextPrimaryFire(CurTime() + 0.6)
    self:SetNextSecondaryFire(CurTime() + 0.6)
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > CurTime() then return end
    self:SetRaised(not self:GetRaised())
    if CLIENT and self:GetRaised() and IsFirstTimePredicted() then
        local vm = self:GetOwner():GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
    end

    self.NextReload = CurTime() + 1
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack(true)
end

function SWEP:DealDamage()
    local anim = self:GetSequenceName(self:GetOwner():GetViewModel():GetSequence())
    self:GetOwner():LagCompensation(true)
    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
        filter = self:GetOwner()
   })

    if not IsValid(tr.Entity) then
        tr = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
            filter = self:GetOwner(),
            mins = Vector(-10, -10, -8),
            maxs = Vector(10, 10, 8)
       })
    end

    if tr.Hit then self:EmitSound(HitSound) end
    local hit = false
    if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
        local dmginfo = DamageInfo()
        local attacker = self:GetOwner()
        if not IsValid(attacker) then attacker = self end
        dmginfo:SetAttacker(attacker)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(math.random(8, 12))
        if anim == "fists_left" then
            dmginfo:SetDamageForce(self:GetOwner():GetRight() * 49125 + self:GetOwner():GetForward() * 99984) -- Yes we need those specific numbers
        elseif anim == "fists_right" then
            dmginfo:SetDamageForce(self:GetOwner():GetRight() * -49124 + self:GetOwner():GetForward() * 99899)
        elseif anim == "fists_uppercut" then
            dmginfo:SetDamageForce(self:GetOwner():GetUp() * 51589 + self:GetOwner():GetForward() * 100128)
            dmginfo:SetDamage(math.random(10, 40))
        end

        tr.Entity:TakeDamageInfo(dmginfo)
        hit = true
    end

    if SERVER and IsValid(tr.Entity) then
        local phys = tr.Entity:GetPhysicsObject()
        if IsValid(phys) then phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 80 * phys:GetMass(), tr.HitPos) end
    end

    if SERVER then
        if hit and anim ~= "fists_uppercut" then
            self:SetCombo(self:GetCombo() + 1)
        else
            self:SetCombo(0)
        end
    end

    self:GetOwner():LagCompensation(false)
end

function SWEP:OnRemove()
    if IsValid(self:GetOwner()) then
        local vm = self:GetOwner():GetViewModel()
        if IsValid(vm) then vm:SetMaterial("") end
    end
end

function SWEP:Holster()
    self:OnRemove()
    return true
end

function SWEP:Deploy()
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
    self:UpdateNextIdle()
    if SERVER then self:SetCombo(0) end
    self:SetRaised(false)
    return true
end

function SWEP:Think()
    if self:GetRaised() then
        local vm = self:GetOwner():GetViewModel()
        local idletime = self:GetNextIdle()
        if idletime > 0 and CurTime() > idletime then
            vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
            self:UpdateNextIdle()
        end

        local meleetime = self:GetNextMeleeAttack()
        if meleetime > 0 and CurTime() > meleetime then
            self:DealDamage()
            self:SetNextMeleeAttack(0)
        end

        if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then self:SetCombo(0) end
    end
end

local index
index = ACT_HL2MP_IDLE
SWEP.ActivityTranslateNotRaised = {}
SWEP.ActivityTranslateNotRaised[ACT_MP_STAND_IDLE] = index
SWEP.ActivityTranslateNotRaised[ACT_MP_WALK] = index + 1
SWEP.ActivityTranslateNotRaised[ACT_MP_RUN] = index + 2
SWEP.ActivityTranslateNotRaised[ACT_MP_CROUCH_IDLE] = index + 3
SWEP.ActivityTranslateNotRaised[ACT_MP_CROUCHWALK] = index + 4
SWEP.ActivityTranslateNotRaised[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = index + 5
SWEP.ActivityTranslateNotRaised[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = index + 5
SWEP.ActivityTranslateNotRaised[ACT_MP_RELOAD_STAND] = index + 6
SWEP.ActivityTranslateNotRaised[ACT_MP_RELOAD_CROUCH] = index + 6
SWEP.ActivityTranslateNotRaised[ACT_MP_JUMP] = ACT_HL2MP_IDLE_DUEL + 7
SWEP.ActivityTranslateNotRaised[ACT_RANGE_ATTACK1] = index + 8
SWEP.ActivityTranslateNotRaised[ACT_MP_SWIM] = index + 9
index = ACT_HL2MP_IDLE_FIST
SWEP.ActivityTranslateRaised = {}
SWEP.ActivityTranslateRaised[ACT_MP_STAND_IDLE] = index
SWEP.ActivityTranslateRaised[ACT_MP_WALK] = index + 1
SWEP.ActivityTranslateRaised[ACT_MP_RUN] = index + 2
SWEP.ActivityTranslateRaised[ACT_MP_CROUCH_IDLE] = index + 3
SWEP.ActivityTranslateRaised[ACT_MP_CROUCHWALK] = index + 4
SWEP.ActivityTranslateRaised[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = index + 5
SWEP.ActivityTranslateRaised[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = index + 5
SWEP.ActivityTranslateRaised[ACT_MP_RELOAD_STAND] = index + 6
SWEP.ActivityTranslateRaised[ACT_MP_RELOAD_CROUCH] = index + 6
SWEP.ActivityTranslateRaised[ACT_MP_JUMP] = index + 7
SWEP.ActivityTranslateRaised[ACT_RANGE_ATTACK1] = index + 8
SWEP.ActivityTranslateRaised[ACT_MP_SWIM] = index + 9
index = nil
function SWEP:TranslateActivity(act)
    if self:GetRaised() then
        if self.ActivityTranslateRaised[act] ~= nil then return self.ActivityTranslateRaised[act] end
    else
        if self.ActivityTranslateNotRaised[act] ~= nil then return self.ActivityTranslateNotRaised[act] end
    end
    return -1
end
