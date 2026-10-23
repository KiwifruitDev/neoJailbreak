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

concommand.Add("jb_lastrequest_start", function(p, _unused_36_56, a)
    if not JB:CanLastRequest() or p:Team() ~= TEAM_PRISONER or not p:Alive() or not a or not a[1] or not a[2] then return end
    local lr = a[1]
    if not JB.ValidLR(JB.LastRequestTypes[lr]) then return end
    local guard = Entity(tonumber(a[2]))
    if not IsValid(guard) or not guard.IsPlayer or not guard:IsPlayer() or guard:Team() ~= TEAM_GUARD or not guard:Alive() then return end
    JB:DebugPrint("Setting up LR for ", p:Nick())
    JB.LastRequest = {
        type = lr,
        guard = guard,
        prisoner = p
   }
end)
