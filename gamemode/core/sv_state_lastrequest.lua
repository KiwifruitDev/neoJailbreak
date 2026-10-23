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

function JB:CanLastRequest()
    return JB:AliveGuards() >= 1 and JB:AlivePrisoners() == 1 and (JB.State == STATE_PLAYING or JB.State == STATE_LASTREQUEST and not JB.ValidLR(JB.LastRequestTypes[JB.LastRequest]) or JB.State == STATE_SETUP)
end

function JB:StartLastRequest(prisoner, lr, guard)
    local function isCombatant(ent)
        return IsValid(ent) and ent:IsPlayer()
    end

    if not self:CanLastRequest() or not isCombatant(prisoner) or prisoner:Team() ~= TEAM_PRISONER or not prisoner:Alive() then return false end
    if not JB.ValidLR(JB.LastRequestTypes[lr]) or not isCombatant(guard) or guard:Team() ~= TEAM_GUARD or not guard:Alive() then return false end
    JB:DebugPrint("Setting up LR for ", prisoner:Nick())
    self.LastRequest = {
        type = lr,
        guard = guard,
        prisoner = prisoner
    }
    return true
end

concommand.Add("jb_lastrequest_start", function(p, _, a)
    if not IsValid(p) or not p:IsPlayer() or not a or not a[1] or not a[2] then return end
    local lr = a[1]
    local guard = Entity(tonumber(a[2]))
    JB:StartLastRequest(p, lr, guard)
end)
