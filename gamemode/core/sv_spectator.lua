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

JB.Gamemode.PlayerSpawnAsSpectator = function(_unused_32_48, ply)
    ply:StripWeapons()
    if ply:Team() == TEAM_UNASSIGNED then
        ply:Spectate(OBS_MODE_FIXED)
        return
    end

    local canspec = {}
    for _, v in ipairs(team.GetPlayers(TEAM_GUARD)) do
        if IsValid(v) and v:Alive() then table.insert(canspec, v) end
    end

    for _, v in ipairs(team.GetPlayers(TEAM_PRISONER)) do
        if IsValid(v) and v:Alive() then table.insert(canspec, v) end
    end

    local target = ply.spec and canspec[ply.spec] or canspec[1]
    if target then
        ply:SpectateEntity(target)
        ply:Spectate(OBS_MODE_CHASE)
    else
        ply:Spectate(OBS_MODE_ROAMING)
    end
end

local CTRL_NEXT = bit.bor(IN_ATTACK, IN_MOVELEFT, IN_FORWARD)
local CTRL_PREV = bit.bor(IN_ATTACK2, IN_MOVERIGHT, IN_BACK)
local CTRL_CHANGE = bit.bor(IN_DUCK)
hook.Add("KeyPress", "JB.KeyPress.HandleSpectateControls", function(p, key)
    if p:GetObserverMode() ~= OBS_MODE_NONE then
        local doNext = tobool(bit.band(key, CTRL_NEXT))
        local doPrev = tobool(bit.band(key, CTRL_PREV))
        local doChange = tobool(bit.band(key, CTRL_CHANGE))
        if doNext or doPrev or doChange then
            JB:DebugPrint(p:Nick() .. " is using spectator controls. " .. tostring(doNext) .. " " .. tostring(doPrev) .. " " .. tostring(doChange))
            if not p.spec then p.spec = 1 end
            local canspec = {}
            for _, v in ipairs(team.GetPlayers(TEAM_GUARD)) do
                if IsValid(v) and v:Alive() then table.insert(canspec, v) end
            end

            for _, v in ipairs(team.GetPlayers(TEAM_PRISONER)) do
                if IsValid(v) and v:Alive() then table.insert(canspec, v) end
            end

            local target = canspec[p.spec] or canspec[1]
            if doChange and p:GetObserverMode() == OBS_MODE_CHASE then
                p:Spectate(OBS_MODE_ROAMING)
                return
            elseif doChange and p:GetObserverMode() == OBS_MODE_ROAMING and target then
                p:Spectate(OBS_MODE_CHASE)
                p:SpectateEntity(target)
                return
            elseif doChange then
                return
            end

            if p:GetObserverMode() == OBS_MODE_CHASE then
                if not canspec or not canspec[1] then
                    JB.DebugPrint("Nobody alive to spectate.")
                    return
                end

                local _unused_97_23 = p.spec
                if doNext then
                    p.spec = p.spec + 1
                    if p.spec > #canspec then p.spec = 0 end
                elseif doPrev then
                    p.spec = p.spec - 1
                    if p.spec < 1 then p.spec = #canspec end
                end

                target = canspec[p.spec]
                if IsValid(target) then p:SpectateEntity(target) end
            end
        end
    end
end)
