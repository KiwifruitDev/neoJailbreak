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

function JB:GetWarden()
    if not IsValid(JB.TRANSMITTER) then return NULL end
    local warden = JB.TRANSMITTER:GetJBWarden()
    if IsValid(warden) and warden:Team() == TEAM_GUARD and warden:Alive() then return warden end
    return NULL
end
