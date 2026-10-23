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
SWEP.PrintName = "Wunderwaffe"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.HoldType = "smg"
SWEP.Base = "weapon_jb_base"
SWEP.Category = "Jailbreak Weapons"
SWEP.Author = "Crudcakes"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/tesla_gun/v_tesla_gun.mdl"
SWEP.WorldModel = "models/wunderwaffe.mdl"
SWEP.Weight = 1000
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Primary.Sound = "weapons/tesla_gun/fire.wav"
SWEP.Primary.Recoil = 1
SWEP.Primary.Damage = 22
SWEP.Primary.NumShots = 1
SWEP.Primary.ClipSize = 4
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "AR2AltFire"
local zapRange = GetConVar("sk_vortigaunt_zap_range")
SWEP.Range = 2 * (zapRange and zapRange:GetFloat() or 100) * 12
SWEP.ShowWorldModel = false
SWEP.Positions = {}
SWEP.Positions[1] = {
    pos = Vector(0, 0, 0),
    ang = Vector(0, 0, 0)
}

SWEP.Positions[2] = {
    pos = Vector(-6.56, -10.08, 2.519),
    ang = Vector(2.4, 0.1, 0)
}

SWEP.Positions[3] = {
    pos = Vector(6.534, -15.827, -5.277),
    ang = Vector(-3.58, 66.97, -26.733)
}

function SWEP:BoxTrace()
    local owner = self:GetOwner()
    local tr = {}
    tr.start = owner:EyePos()
    tr.endpos = tr.start + owner:EyeAngles():Forward() * 1000000
    tr.filter = owner
    tr.mask = MASK_SHOT
    tr.mins = Vector(-5, -5, -5)
    tr.maxs = Vector(5, 5, 5)
    local Trace = util.TraceHull(tr)
    return Trace
end

function SWEP:PrimaryAttack()
    if self:GetNWMode() == MODE_SPRINT then return end
    local delay = self.Primary.Burst > 0 and self.Primary.Delay * (self.Primary.Burst + 1) or self.Primary.Delay
    if self:Clip1() <= 0 then
        self:SetNextPrimaryFire(CurTime() + delay)
        self:EmitSound("Weapon_Pistol.Empty")
        return
    end

    self:SetNextPrimaryFire(CurTime() + delay)
    self:JB_ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetNWLastShoot(), self.Primary.NumShots)
    self:Shoot()
    self.LastShoot = CurTime()
    if SERVER then
        self:GetOwner():EmitSound(self.Primary.Sound, 100, math.random(95, 105))
        if self:GetOwner():GetNWString("powerup") == "gunpunt" and self:Clip1() <= self.Primary.ClipSize / 2 then --punting should only be allowed once your clip size is appropriate
            self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * -150)
        end

        local dmginfo = DamageInfo()
        local eyetrace = self:BoxTrace()
        local maxzaprange = 150
        dmginfo:SetDamage(1000)
        dmginfo:SetDamageType(DMG_SHOCK)
        dmginfo:SetAttacker(self:GetOwner())
        dmginfo:SetInflictor(self:GetOwner():GetActiveWeapon())
        dmginfo:SetDamageForce(Vector(0, 0, 1000))
        if IsValid(eyetrace.Entity) then
            eyetrace.Entity:TakeDamageInfo(dmginfo)
            local previousEntities = {
                [eyetrace.Entity] = true
           }

            local sourceEntity = eyetrace.Entity
            for _ = 1, 9 do
                local nextEntity = self:FindNearestEntity(sourceEntity:GetPos(), maxzaprange, previousEntities)
                if not IsValid(nextEntity) then break end
                util.ParticleTracerEx(self.ArcEffect, sourceEntity:GetPos(), nextEntity:GetPos(), true, 1, 1)
                nextEntity:TakeDamageInfo(dmginfo)
                previousEntities[nextEntity] = true
                sourceEntity = nextEntity
            end
        end
    end

    self:TakePrimaryAmmo(1)
    if self:Clip1() <= 0 and tobool(self:GetOwner():GetInfoNum("jb_cl_option_autoreload", "1")) then self:Reload() end
end

function SWEP:ShootEffect(EFFECTSTR, _unused_136_40, endpos)
    local pPlayer = self:GetOwner()
    if not pPlayer then return end
    local view
    if CLIENT then
        view = GetViewEntity()
    else
        view = pPlayer:GetViewEntity()
    end

    if not pPlayer:IsNPC() and view:IsPlayer() then
        util.ParticleTracerEx(EFFECTSTR, self:GetAttachment(self:LookupAttachment("muzzle")).Pos, endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment("muzzle"))
    else
        util.ParticleTracerEx(EFFECTSTR, pPlayer:GetAttachment(pPlayer:LookupAttachment("anim_attachment_rh")).Pos, endpos, true, pPlayer:EntIndex(), pPlayer:LookupAttachment("anim_attachment_rh"))
    end
end

function SWEP:Shoot(_unused_153_22, effect)
    local pPlayer = self:GetOwner()
    if not pPlayer then return end
    local traceres = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * self.Range, self:GetOwner())
    self:ShootEffect(effect or "tesla_beam", pPlayer:EyePos(), traceres.HitPos)
end

function SWEP:FindNearestEntity(pos, range, excludedEntities)
    local nearestEnt
    for _, entity in pairs(ents.FindByClass("npc_*")) do
        local distance = pos:Distance(entity:GetPos())
        if not excludedEntities[entity] and distance <= range and distance ~= 0 then
            nearestEnt = entity
            range = distance
        end
    end
    return nearestEnt
end
