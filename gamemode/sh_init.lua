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

local config = {}
local function makeConfig(name, default)
    if SERVER then CreateConVar(name, default, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_DONTRECORD}) end
    return {
        name = name,
        default = default
   }
end

config.debug = makeConfig("jb_config_debug", "0")
config.font = makeConfig("jb_config_font", "Roboto")
config.website = makeConfig("jb_config_website", "hi there")
config.maxWardenItems = makeConfig("jb_config_max_warden_items", "20")
config.maxWardenRounds = makeConfig("jb_config_max_warden_rounds", "3")
config.joinTime = makeConfig("jb_config_jointime", "20")
config.setupTime = makeConfig("jb_config_setuptime", "60")
config.guardsAllowed = makeConfig("jb_config_guards_allowed", "30")
config.rebelSensitivity = makeConfig("jb_config_rebel_sensitivity", "2")
config.guardPlaytime = makeConfig("jb_config_guards_playtime", "0")
config.prisonerNameChange = makeConfig("jb_config_prisoners_namechange", "0")
config.wardenControl = makeConfig("jb_config_warden_control_enabled", "1")
config.prisonerSpecialChance = makeConfig("jb_config_prisoner_special_chance", "10")
config.knivesAreConcealed = makeConfig("jb_config_knives_are_concealed", "1")
config.roundsPerMap = makeConfig("jb_config_rounds_per_map", "15")
config.notifyLG = makeConfig("jb_config_notify_lastguard", 1)
-- meta stuff
JB = {}
JB._IndexCallback = {} -- {get = function() end, set = function() end}
setmetatable(JB, {
    __index = function(_, key)
        if key == "Gamemode" then return GM or GAMEMODE or {} end
        if JB._IndexCallback[key] and JB._IndexCallback[key].get then return JB._IndexCallback[key].get() end
        return nil
    end,
    __newindex = function(t, key, value)
        if JB._IndexCallback[key] and JB._IndexCallback[key].set then
            JB._IndexCallback[key].set(value)
            return nil
        end

        rawset(t, key, value)
        return nil
    end
})

JB.Config = {}
setmetatable(JB.Config, {
    __index = function(_, key)
        if config[key] then
            if SERVER then
                local convar = GetConVar(config[key].name)
                local val = convar and convar:GetString()
                return val and val ~= "" and val or config[key] and config[key].default or "0"
            elseif CLIENT then
                return config[key].v or config[key].default
            end
        end
        return nil
    end
})

-- debug
function JB:DebugPrint(...)
    if self.Config.debug and self.Config.debug == "1" then
        MsgC(Color(220, 2420, 220), "[JB DEBUG] [")
        MsgC(SERVER and Color(90, 150, 255) or Color(255, 255, 90), SERVER and "SERVER" or "CLIENT")
        MsgC(Color(220, 220, 220), "] [" .. os.date() .. "]\t\t")
        MsgC(Color(255, 255, 255), ...)
        Msg("\n")
    end
end

-- some networking
if CLIENT then
    net.Receive("JB.FetchConfig", function()
        local receivedConfig = net.ReadTable() or {}
        for key, value in pairs(receivedConfig) do
            if config[key] then
                config[key].v = value
            end
        end

        JB:DebugPrint("Config received!")
    end)

    hook.Add("InitPostEntity", "JB.FetchConfig.Load", function()
        net.Start("JB.FetchConfig")
        net.SendToServer()
        hook.Remove("InitPostEntity", "JB.FetchConfig.Load")
        JB:DebugPrint("Requesting config...")
    end)
elseif SERVER then
    util.AddNetworkString("JB.FetchConfig")
    net.Receive("JB.FetchConfig", function(_, ply)
        JB:DebugPrint("Received config request by: " .. ply:Nick())
        local configValues = {}
        for key in pairs(config) do
            configValues[key] = JB.Config[key]
        end

        net.Start("JB.FetchConfig")
        net.WriteTable(configValues)
        net.Send(ply)
    end)
end

-- dumb stuff I'm forced into adding
JB.Gamemode.TeamBased = true
JB.Gamemode.Name = "Jail Break"
-- utility functions
local loadFolder = function(folder, shared)
    local path = "jailbreak/gamemode/" .. folder .. "/"
    for _, name in pairs(file.Find(path .. "*.lua", "LUA")) do
        local runtype = shared or "sh"
        if not shared then runtype = string.Left(name, 2) end
        if not runtype or runtype ~= "sv" and runtype ~= "sh" and runtype ~= "cl" then return false end
        if SERVER then
            if runtype == "sv" then
                JB:DebugPrint("Loading file: " .. name)
                include(folder .. "/" .. name)
            elseif runtype == "sh" then
                JB:DebugPrint("Loading file: " .. name)
                include(folder .. "/" .. name)
                AddCSLuaFile(folder .. "/" .. name)
            elseif runtype == "cl" then
                AddCSLuaFile(folder .. "/" .. name)
            end
        elseif CLIENT then
            if runtype == "sh" or runtype == "cl" then
                JB:DebugPrint("Loading file: " .. name)
                include(folder .. "/" .. name)
            end
        end
    end
    return true
end

JB.Util = {}
assert(loadFolder("util") and loadFolder("core") and loadFolder("scriptdays", "sh") and loadFolder("classes", "sh") and loadFolder("lastrequests", "sh") and loadFolder("vgui", "cl"), "Failed to load Jail Break 7! Contact a developer!")
