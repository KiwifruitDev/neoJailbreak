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
ENT.Type = "anim"
ENT.Base = "base_anim"
function ENT:Initialize()
    if not SERVER then return end

    self:SetModel("models/player/police.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)

    self:ResetSequence(self:LookupSequence("pose_standing_01"))
end

function ENT:Use(p)
    local randomHealth = {"I got just the right thing for you.", "Need a patch? I got something for ya.", "Your health is low, I can patch ya up if you want.", "Don't get me wrong but I believe you need medical assistance, correct?", "Need a medic quick? I can help you with that."}
    local randomGuns = {"Got somethings for ya to try, willing to buy?", "Guns, guns, guns, I got some guns", "While not drugs, I could hook you up with some guns", "Want some guns, you've come to the right place.", "Totally legal gun exchange, right here in Jailbreak."}
    local randomOfficer = {"Everything is under control, officer!", "Totally disarmed here, officer!", "Nothing illegal going on here, officer!", "Nothing suspicious going on here, officer!", "No crimes have been committed here, officer!", "Officer, I must say it is a beautiful day outside.", "Officer, how's the weather like?"}
    if IsValid(p) and p:Health() < 100 and p:Team() ~= TEAM_GUARD then
        p:ChatPrint(table.Random(randomHealth))
        p:SendLua("JB.MENU_HEAL()")
    elseif IsValid(p) and p:Health() >= 100 and p:Team() ~= TEAM_GUARD then
        if p:GetNWBool("boughtweapon") == false or p:GetNWBool("boughtweapon") == nil then
            p:ChatPrint(table.Random(randomGuns))
            p:SendLua("JB.MENU_GUNMENU()")
        end
    elseif IsValid(p) and p:Team() == TEAM_GUARD then
        p:ChatPrint(table.Random(randomOfficer))
    end
end

function ENT:Draw()
    self:DrawModel()
end
