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

local randomGhostSFX = {"otterjailbreak/lc_ghost01.mp3", "otterjailbreak/lc_ghost02.mp3", "otterjailbreak/lc_ghost03.mp3", "otterjailbreak/lc_ghost04.mp3"}
local undroppableWeapons = {"weapon_physcannon", "gmod_camera", "gmod_tool", "weapon_jb_fists"}
local drop = function(ply, _unused_34_30, _unused_34_36)
    if table.HasValue(JB.LastRequestPlayers, ply) and JB.LastRequestTypes[JB.LastRequest] and not JB.LastRequestTypes[JB.LastRequest]:GetCanDropWeapons() then return end
    JB:DebugPrint(ply:Nick() .. " dropped his/her weapon")
    local weapon = ply:GetActiveWeapon()
    for _unused_38_9, v in pairs(undroppableWeapons) do
        if IsValid(weapon) and v == weapon:GetClass() then return false end
    end

    if IsValid(weapon) then
        JB:DamageLog_AddPlayerDrop(ply, weapon:GetClass())
        weapon.IsDropped = true
        weapon.BeingPickedUp = false
        ply:DropWeapon(weapon)
    end
end

concommand.Add("jb_dropweapon", drop)
JB.Util.addChatCommand("drop", drop)
local bc = function(ply, _unused_52_28, args) if ply:IsAdmin() then JB:BroadcastNotification(table.concat(args, " ")) end end
concommand.Add("jb_broadcast", bc)
JB.Util.addChatCommand("broadcast", bc)
local addks = function(ply, _unused_55_31, args) if ply:IsAdmin() then ply:SetNWInt("killstreak", ply:GetNWInt("killstreak") + tonumber(table.concat(args, " "))) end end
concommand.Add("jb_addks", addks)
JB.Util.addChatCommand("addks", addks)
local setks = function(ply, _unused_58_31, args)
    if ply:IsAdmin() then
        ply:SetNWInt("killstreak", tonumber(table.concat(args, " ")))
        ply:SetPos(Vector(2638.454834, 4929.103516, 640.380859))
    end
end

concommand.Add("jb_setks", setks)
JB.Util.addChatCommand("setks", setks)
local givewep = function(ply, _unused_67_33, args)
    if ply:IsAdmin() then
        ply:Give(table.concat(args, " "))
        ply:SelectWeapon(table.concat(args, " "))
    end
end

concommand.Add("jb_give", givewep)
JB.Util.addChatCommand("give", givewep)
local selwep = function(ply, _unused_76_32, args) ply:SelectWeapon(table.concat(args, "")) end
concommand.Add("jb_select", selwep)
JB.Util.addChatCommand("select", selwep)
local wunderwaffe = function(ply, _unused_79_37, _unused_79_43)
    if ply:IsAdmin() then
        for _, targetPlayer in ipairs(player.GetAll()) do
            targetPlayer:Give("weapon_jb_teslagun")
        end
    end
end

concommand.Add("jb_wunderwaffe", wunderwaffe)
JB.Util.addChatCommand("wunderwaffe", wunderwaffe)
local fc = function(ply, _unused_89_28, _unused_89_34)
    if ply:IsAdmin() and #team.GetPlayers(TEAM_GUARD) >= 1 and #team.GetPlayers(TEAM_PRISONER) >= 1 then
        if SERVER then
            game.ConsoleCommand("sv_gravity 600\n")
            game.ConsoleCommand("sv_friction 8\n")
        end

        JB:DebugPrint(ply:Nick() .. " has forcibly ended the round!")
        JB:EndRound()
    end
end

concommand.Add("jb_forceround", fc)
JB.Util.addChatCommand("forceround", fc)
local pickup = function(p)
    local e = p:GetEyeTrace().Entity
    if table.HasValue(JB.LastRequestPlayers, p) and JB.LastRequestTypes[JB.LastRequest] and not JB.LastRequestTypes[JB.LastRequest]:GetCanPickupWeapons() then return end
    if IsValid(e) and p:Alive() and p:CanPickupWeapon(e) then
        e.BeingPickedUp = p
        JB:DamageLog_AddPlayerPickup(p, e:GetClass())
    end
end

concommand.Add("jb_pickup", pickup)
JB.Util.addChatCommand("pickup", pickup)
local function teamSwitch(p, cmd)
    if not IsValid(p) then return end
    if cmd == "jb_team_select_guard" and JB:GetGuardsAllowed() > #team.GetPlayers(TEAM_GUARD) and p:Team() ~= TEAM_GUARD then
        if p:Alive() and JB.State ~= STATE_MAPVOTE and JB.State ~= STATE_IDLE and JB:AlivePrisoners() > 1 then
            p:SendLua(string.format("surface.PlaySound(%q)", table.Random(randomGhostSFX)))
        end

        p:SetTeam(TEAM_GUARD)
        p:KillSilent()
        p:SendNotification("Switched to guards")
        hook.Call("JailBreakPlayerSwitchTeam", JB.Gamemode, p, p:Team())
        p:SetFrags(0)
        p:SetDeaths(0)
    elseif cmd == "jb_team_select_prisoner" and p:Team() ~= TEAM_PRISONER then
        if p:Alive() and JB.State ~= STATE_MAPVOTE and JB.State ~= STATE_IDLE and JB:AliveGuards() > 1 then p:SendLua(string.format("surface.PlaySound(%q)", table.Random(randomGhostSFX))) end
        p:SetTeam(TEAM_PRISONER)
        p:KillSilent()
        p:SendNotification("Switched to prisoners")
        hook.Call("JailBreakPlayerSwitchTeam", JB.Gamemode, p, p:Team())
        p:SetFrags(0)
        p:SetDeaths(0)
    elseif cmd == "jb_team_select_spectator" and p:Team() ~= TEAM_SPECTATOR then
        p:SetTeam(TEAM_SPECTATOR)
        p:Spawn()
        p:SendNotification("Switched to spectator mode")
        hook.Call("JailBreakPlayerSwitchTeam", JB.Gamemode, p, p:Team())
        p:SetFrags(0)
        p:SetDeaths(0)
    end
end

concommand.Add("jb_team_select_prisoner", teamSwitch)
concommand.Add("jb_team_select_guard", teamSwitch)
concommand.Add("jb_team_select_spectator", teamSwitch)
JB.Util.addChatCommand("guard", function(p) p:ConCommand("jb_team_select_guard") end)
JB.Util.addChatCommand("prisoner", function(p) p:ConCommand("jb_team_select_prisoner") end)
JB.Util.addChatCommand("spectator", function(p) p:ConCommand("jb_team_select_spectator") end)
local teamswap = function(p)
    if p:Team() == TEAM_PRISONER then
        p:ConCommand("jb_team_select_guard")
    else
        p:ConCommand("jb_team_select_prisoner")
    end
end

JB.Util.addChatCommand("teamswap", teamswap)
JB.Util.addChatCommand("swap", teamswap)
JB.Util.addChatCommand("swapteam", teamswap)
concommand.Add("jb_admin_spawnmenu", function(ply)
    if not ply:IsSuperAdmin() then return end
    ply:ChatPrint("Opened spawn menu.")
    ply:SendLua("JB.MENU_SPAWNMENU()")
end)

concommand.Add("jb_admin_swap", function(p, _unused_172_49, a)
    if not IsValid(p) or not p:IsAdmin() then return end
    local steamid = a[1]
    if not steamid then return end
    for _unused_176_9, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            if p:Alive() then p:SendLua(string.format("surface.PlaySound(%q)", table.Random(randomGhostSFX))) end
            if v:Team() == TEAM_GUARD then
                v:SetTeam(TEAM_PRISONER)
                v:KillSilent()
                v:SendNotification("Forced to prisoners")
                hook.Call("JailBreakPlayerSwitchTeam", JB.Gamemode, p, p:Team())
            else
                v:SetTeam(TEAM_GUARD)
                v:KillSilent()
                v:SendNotification("Forced to guards")
                hook.Call("JailBreakPlayerSwitchTeam", JB.Gamemode, p, p:Team())
            end

            for _unused_191_17, it in ipairs(player.GetAll()) do
                it:ChatPrint(p:Nick() .. " has force swapped " .. v:Nick() .. ".")
            end
            return
        end
    end

    p:ChatPrint("User not found! " .. steamid)
end)

concommand.Add("jb_admin_swap_spectator", function(p, _unused_201_59, a)
    if not IsValid(p) or not p:IsAdmin() then return end
    local steamid = a[1]
    if not steamid then return end
    for _unused_205_9, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            v:SetTeam(TEAM_SPECTATOR)
            v:Kill()
            for _unused_209_17, it in ipairs(player.GetAll()) do
                it:ChatPrint(p:Nick() .. " has made " .. v:Nick() .. " a spectator.")
            end
            return
        end
    end

    p:ChatPrint("User not found! " .. steamid)
end)

concommand.Add("jb_admin_revive", function(p, _unused_219_51, a)
    if not IsValid(p) or not p:IsAdmin() then return end
    local steamid = a[1]
    if not steamid then return end
    for _unused_223_9, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            v._jb_forceRespawn = true
            v:Spawn()
            for _unused_227_17, it in ipairs(player.GetAll()) do
                it:ChatPrint(p:Nick() .. " has revived " .. v:Nick() .. ".")
            end
            return
        end
    end

    p:ChatPrint("User not found! " .. steamid)
end)
