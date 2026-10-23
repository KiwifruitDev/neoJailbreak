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

JB:RegisterScriptday("GangWarDay", {
    Name = "Gang War Day",
    Description = "Prisoners and guards are now the Bloods and Crips. Each team will have Mac 10s, USPs, and knives to fight each other with.",
    Icon = "icon16/gun.png",
    Start = function()
        JB:BroadcastNotification("The warden has initiated Gang War Day!")
        for _, ply in ipairs(player.GetAll()) do
            ply:SendLua(string.format("surface.PlaySound(%q)", "#otterjailbreak/gangwarday.wav"))
            ply:StripWeapons()
            ply:Give("weapon_jb_fists")
            ply:Give("weapon_jb_knife")
            ply:Give("weapon_jb_usp")
            ply:Give("weapon_jb_mac10")
            ply:SelectWeapon("weapon_jb_mac10")
        end

        for _, ply in ipairs(team.GetPlayers(TEAM_GUARD)) do
            ply:SetModel("models/player/cripz/slow_3.mdl")
        end
    end,
    GetTeamName = function(teamID, defaultName)
        if teamID == TEAM_PRISONER then return "Bloods" end
        if teamID == TEAM_GUARD then return "Crips" end
        return defaultName
    end,
    GetRoundEndMessage = function(winner)
        if winner == TEAM_PRISONER or winner == TEAM_GUARD then
            return JB:GetTeamName(winner) .. " win"
        end
        return "Draw"
    end
})
