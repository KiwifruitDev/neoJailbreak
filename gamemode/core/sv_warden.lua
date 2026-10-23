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

function JB:ClaimWarden(p, automatic)
    if not IsValid(p) or p:Team() ~= TEAM_GUARD or JB.State ~= STATE_SETUP or IsValid(JB:GetWarden()) then return false end
    if not automatic and p.wardenRounds and p.wardenRounds >= tonumber(JB.Config.maxWardenRounds) and CurTime() - JB.RoundStartTime < 20 then
        p:SendQuickNotification("You have to give others a chance to claim warden.")
        return false
    end

    for _, ply in ipairs(player.GetAll()) do
        ply:SendLua(string.format("surface.PlaySound(%q)", "otterjailbreak/lc_spawncount.mp3"))
    end

    p:AddWardenStatus()
    if not p.wardenRounds then
        p.wardenRounds = 1
    else
        p.wardenRounds = p.wardenRounds + 1
    end

    for _, v in pairs(team.GetPlayers(TEAM_GUARD)) do
        if IsValid(v) and v ~= p and p.wardenRounds then p.wardenRounds = 0 end
    end

    hook.Call("JailBreakClaimWarden", JB.Gamemode, p, p.wardenRounds)
    return true
end

local function claimWarden(p)
    JB:ClaimWarden(p)
end

JB.Util.addChatCommand("warden", claimWarden)
concommand.Add("jb_claim_warden", claimWarden)
concommand.Add("jb_warden_changecontrol", function(p, _, a)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not IsValid(JB.TRANSMITTER) then return end
    local opt = a[1]
    local val = a[2]
    if not opt or not val then
        return
    elseif opt == "PVP" then
        JB.TRANSMITTER:SetJBWarden_PVPDamage(tobool(val))
        JB:BroadcastNotification("Friendly fire is now " .. (tobool(val) and "enabled" or "disabled"))
    elseif opt == "Pickup" then
        JB.TRANSMITTER:SetJBWarden_ItemPickup(tobool(val))
        JB:BroadcastNotification("Item pickup is now " .. (tobool(val) and "enabled" or "disabled"))
    end

    hook.Call("JailBreakWardenControlChanged", JB.Gamemode, p, opt, val)
end)

local function spawnProp(p, typ, model)
    local spawned = 0
    for _, v in pairs(ents.GetAll()) do
        if v and IsValid(v) and v.wardenSpawned then spawned = spawned + 1 end
    end

    if spawned > tonumber(JB.Config.maxWardenItems) then
        p:SendQuickNotification("You can not spawn over " .. tostring(JB.Config.maxWardenItems) .. " items.")
        return
    end

    local prop = ents.Create(typ)
    prop:SetAngles(p:GetAngles())
    prop:SetPos(p:EyePos() + p:GetAngles():Forward() * 60)
    if model then prop:SetModel(model) end
    prop:Spawn()
    prop:Activate()
    prop.wardenSpawned = true
    hook.Call("JailBreakWardenSpawnProp", JB.Gamemode, p, typ, model)
end

function JB:WardenSpawnProp(p, typ, model)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return false end
    spawnProp(p, typ, model)
    return true
end

local function adminSpawn(p, typ, model)
    local prop = ents.Create(typ)
    prop:SetAngles(p:GetAngles())
    prop:SetPos(p:EyePos() + p:GetAngles():Forward() * 60)
    if model then prop:SetModel(model) end
    prop:Spawn()
    prop:Activate()
end

concommand.Add("jb_admin_spawn", function(p, _, a)
    if not IsValid(p) or not p:IsAdmin() then return end
    local opt = a[1]
    if not opt then
        return
    elseif opt == "HotDog" then
        adminSpawn(p, "jb_hotdog")
    elseif opt == "Crate" then
        adminSpawn(p, "prop_physics_multiplayer", "models/props_junk/wood_crate001a.mdl")
    elseif opt == "Blockade" then
        adminSpawn(p, "prop_physics_multiplayer", "models/props_trainstation/TrackSign02.mdl")
    elseif opt == "AmmoBox" then
        adminSpawn(p, "jb_ammobox")
    elseif opt == "Dickhead" then
        adminSpawn(p, "jb_detective_dickhead")
    end
end)

concommand.Add("jb_warden_opendoors", function(p)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    JB:BroadcastNotification("All cells and doors have been toggled!")
    for _, v in ipairs(ents.FindByClass("func_door")) do
        v:Fire("Toggle", 1)
    end

    for _, v in ipairs(ents.FindByClass("func_door_rotating")) do
        v:Fire("Toggle", 1)
    end

    for _, v in ipairs(ents.FindByClass("func_movelinear")) do
        v:Fire("Toggle", 1)
    end
end)

concommand.Add("jb_warden_spawn", function(p, _, a)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    local opt = a[1]
    if not opt then
        return
    elseif opt == "HotDog" then
        JB:WardenSpawnProp(p, "jb_hotdog")
    elseif opt == "Crate" then
        JB:WardenSpawnProp(p, "prop_physics_multiplayer", "models/props_junk/wood_crate001a.mdl")
    elseif opt == "Blockade" then
        JB:WardenSpawnProp(p, "prop_physics_multiplayer", "models/props_trainstation/TrackSign02.mdl")
    elseif opt == "AmmoBox" then
        JB:WardenSpawnProp(p, "jb_ammobox")
    end
end)

concommand.Add("jb_warden_scriptday", function(p, _, a)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    if not IsValid(JB.TRANSMITTER) or JB.TRANSMITTER:GetJBScriptday() ~= "" then return end
    local scriptdayID = a[1]
    local scriptday = JB:GetScriptday(scriptdayID)
    if not scriptday then return end

    JB.TRANSMITTER:SetJBScriptday(scriptdayID)
    for _, v in ipairs(ents.FindByClass("func_door")) do
        v:Fire("Open", 1)
    end

    for _, v in ipairs(ents.FindByClass("func_door_rotating")) do
        v:Fire("Open", 1)
    end

    for _, v in ipairs(ents.FindByClass("func_movelinear")) do
        v:Fire("Open", 1)
    end

    if isfunction(scriptday.Start) then
        scriptday.Start(p)
    end

    hook.Call("JailBreakScriptdayStarted", JB.Gamemode, p, scriptdayID, scriptday)
end)

local pointerRemove = -1
function JB:WardenPlacePointer(p, typ, pos)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not IsValid(JB.TRANSMITTER) then return false end
    if not isvector(pos) then return false end
    JB.TRANSMITTER:SetJBWarden_PointerPos(pos)
    JB.TRANSMITTER:SetJBWarden_PointerType(typ)
    pointerRemove = CurTime() + 120
    hook.Call("JailBreakWardenPlacePointer", JB.Gamemode, p, typ, pos)
    return true
end

concommand.Add("jb_warden_placepointer", function(p, _, a)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() then return end
    local typ = tostring(a[1])
    if not typ then return end
    local pos = p:GetEyeTrace().HitPos
    if typ ~= "0" then
        JB:DebugPrint("Warden " .. p:Nick() .. " has placed a marker at " .. tostring(pos))
        JB:BroadcastQuickNotification("The warden has placed a marker")
        for _, ply in ipairs(player.GetAll()) do
            if typ == "generic" then
                ply:SendLua(string.format("surface.PlaySound(%q)", "coach/coach_go_here.wav"))
            elseif typ == "exclamation" then
                ply:SendLua(string.format("surface.PlaySound(%q)", "coach/coach_attack_here.wav"))
            elseif typ == "question" then
                ply:SendLua(string.format("surface.PlaySound(%q)", "coach/coach_look_here.wav"))
            elseif typ == "line" then
                ply:SendLua(string.format("surface.PlaySound(%q)", "coach/coach_go_here.wav"))
            elseif typ == "cross" then
                ply:SendLua(string.format("surface.PlaySound(%q)", "coach/coach_defend_here.wav"))
            end
        end
    end

    pointerRemove = CurTime() + 120
    JB.TRANSMITTER:SetJBWarden_PointerPos(pos)
    JB.TRANSMITTER:SetJBWarden_PointerType(typ)
    hook.Call("JailBreakWardenPlacePointer", JB.Gamemode, p, typ, pos)
end)

hook.Add("Think", "JB.Think.PointerTimeout", function() if CurTime() > pointerRemove and pointerRemove ~= -1 then JB.TRANSMITTER:SetJBWarden_PointerType("0") end end)
