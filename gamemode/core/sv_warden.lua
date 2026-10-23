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

local function claimWarden(p, _unused_32_33, _unused_32_37)
    if not IsValid(p) or p:Team() ~= TEAM_GUARD or JB.State ~= STATE_SETUP or IsValid(JB:GetWarden()) then return end
    if p.wardenRounds and p.wardenRounds >= tonumber(JB.Config.maxWardenRounds) and CurTime() - JB.RoundStartTime < 20 then
        p:SendQuickNotification("You have to give others a chance to claim warden.")
        return
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
end

JB.Util.addChatCommand("warden", claimWarden)
concommand.Add("jb_claim_warden", claimWarden)
concommand.Add("jb_warden_changecontrol", function(p, _unused_59_59, a)
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
    for _unused_78_9, v in pairs(ents.GetAll()) do
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

local function adminSpawn(p, typ, model)
    local prop = ents.Create(typ)
    prop:SetAngles(p:GetAngles())
    prop:SetPos(p:EyePos() + p:GetAngles():Forward() * 60)
    if model then prop:SetModel(model) end
    prop:Spawn()
    prop:Activate()
end

concommand.Add("jb_admin_spawn", function(p, _unused_106_50, a)
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

concommand.Add("jb_warden_opendoors", function(p, _unused_125_55, _unused_125_59)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    JB:BroadcastNotification("All cells and doors have been toggled!")
    for _unused_128_9, v in ipairs(ents.FindByClass("func_door")) do
        v:Fire("Toggle", 1)
    end

    for _unused_132_9, v in ipairs(ents.FindByClass("func_door_rotating")) do
        v:Fire("Toggle", 1)
    end

    for _unused_136_9, v in ipairs(ents.FindByClass("func_movelinear")) do
        v:Fire("Toggle", 1)
    end
end)

concommand.Add("jb_warden_grapplinghooks", function(p, _unused_141_60, _unused_141_64)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    JB:BroadcastNotification("All prisoners now have grappling hooks!")
    for _, ply in ipairs(team.GetPlayers(TEAM_PRISONER)) do
        local grapple = ents.Create("sent_grapplehook_bpack")
        grapple:SetSlotName("sent_grapplehook_bpack")
        grapple:Spawn()
        grapple:SetKey(36)
        if not grapple:Attach(ply, true) then
            grapple:Remove()
            return
        end
    end
end)

concommand.Add("jb_warden_spawn", function(p, _unused_158_51, a)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    local opt = a[1]
    if not opt then
        return
    elseif opt == "HotDog" then
        spawnProp(p, "jb_hotdog")
    elseif opt == "Crate" then
        spawnProp(p, "prop_physics_multiplayer", "models/props_junk/wood_crate001a.mdl")
    elseif opt == "Blockade" then
        spawnProp(p, "prop_physics_multiplayer", "models/props_trainstation/TrackSign02.mdl")
    elseif opt == "AmmoBox" then
        spawnProp(p, "jb_ammobox")
    end
end)

concommand.Add("jb_warden_scriptday", function(p, _unused_174_55, a)
    if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
    if IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBScriptday() == "" then
        local lr = a[1]
        JB.TRANSMITTER:SetJBScriptday(lr)
        for _unused_179_13, v in ipairs(ents.FindByClass("func_door")) do
            v:Fire("Open", 1)
        end

        for _unused_183_13, v in ipairs(ents.FindByClass("func_door_rotating")) do
            v:Fire("Open", 1)
        end

        for _unused_187_13, v in ipairs(ents.FindByClass("func_movelinear")) do
            v:Fire("Open", 1)
        end

        --ADD SCRIPTDAYS HERE AND IN SV_MENU_SCRIPTDAY.LUA--
        if lr == "GangWarDay" then
            JB:BroadcastNotification("The warden has initiated Gang War Day!")
            JB:BroadcastNotification("All prisoners now have grappling hooks!")
            for _, ply in ipairs(player.GetAll()) do
                ply:SendLua(string.format("surface.PlaySound(%q)", "otterjailbreak/gangwarday.wav"))
                ply:StripWeapons()
                ply:Give("weapon_jb_fists")
                ply:Give("weapon_jb_knife")
                ply:Give("weapon_jb_usp")
                ply:Give("weapon_jb_mac10")
                ply:SelectWeapon("weapon_jb_mac10")
            end

            for _, ply in ipairs(team.GetPlayers(TEAM_PRISONER)) do
                ply:SetModel("models/player/bloodz/slow_3.mdl")
                local grapple = ents.Create("sent_grapplehook_bpack")
                grapple:SetSlotName("sent_grapplehook_bpack")
                grapple:Spawn()
                grapple:SetKey(36)
                if not grapple:Attach(ply, true) then
                    grapple:Remove()
                    return
                end
            end

            for _, ply in ipairs(team.GetPlayers(TEAM_GUARD)) do
                ply:SetModel("models/player/cripz/slow_3.mdl")
            end
        end
    end
end)

local pointerRemove = -1
concommand.Add("jb_warden_placepointer", function(p, _unused_228_58, a)
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
