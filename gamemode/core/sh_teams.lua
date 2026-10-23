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

TEAM_GUARD = 2
TEAM_PRISONER = 1
JB.Gamemode.CreateTeams = function()
    team.SetUp(TEAM_GUARD, "Guards", JB.Color["#0066FF"])
    team.SetUp(TEAM_PRISONER, "Prisoners", JB.Color["#E31100"])
    team.SetSpawnPoint(TEAM_GUARD, "info_player_counterterrorist")
    team.SetSpawnPoint(TEAM_PRISONER, "info_player_terrorist")
    team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn")
end

function JB:GetTeamPlayers(teamID)
    local players = team.GetPlayers(teamID)
    return players
end

function JB:IsAlive(ent)
    if not IsValid(ent) then return false end
    return ent:Alive()
end

-- Utility functions
function JB:GetGuardsAllowed()
    local guards = #JB:GetTeamPlayers(TEAM_GUARD)
    if guards <= 0 then return 1 end
    return math.ceil((guards + #JB:GetTeamPlayers(TEAM_PRISONER)) * tonumber(JB.Config.guardsAllowed) / 100)
end

function JB:BalanceTeams()
    local guards = JB:GetTeamPlayers(TEAM_GUARD)
    local prisoners = JB:GetTeamPlayers(TEAM_PRISONER)
    if #guards + #prisoners <= 1 then return end

    local guardsAllowed = JB:GetGuardsAllowed()
    local movedPlayers = {}
    while #guards > guardsAllowed do
        local guard = table.remove(guards, math.random(#guards))
        if IsValid(guard) then
            guard:SetTeam(TEAM_PRISONER)
            if guard:IsPlayer() then
                guard:ChatPrint("You were moved to Prisoners to make the game more fair.")
            end
            movedPlayers[#movedPlayers + 1] = guard
        end
    end

    return movedPlayers
end

local count
function JB:AliveGuards()
    count = 0
    for _, v in pairs(JB:GetTeamPlayers(TEAM_GUARD)) do
        if JB:IsAlive(v) then count = count + 1 end
    end
    return count
end

function JB:AlivePrisoners()
    count = 0
    for _, v in pairs(JB:GetTeamPlayers(TEAM_PRISONER)) do
        if JB:IsAlive(v) then count = count + 1 end
    end
    return count
end

--Useless gooks
function JB.Gamemode:PlayerJoinTeam()
    return false
end

function JB.Gamemode:PlayerRequestTeam()
    return false
end
