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

function JB.Util.iterate(tab)
    local wrap = {}
    setmetatable(wrap, {
        __index = function(_, req)
            return function(...)
                for _, v in pairs(tab) do
                    if not (v[req] and type(v[req]) == "function") then continue end
                    args = {...}
                    for i, arg in ipairs(args) do
                        if arg == wrap then rawset(args, i, v) end
                    end

                    v[req](unpack(args))
                end
                return wrap
            end
        end
   })
    return wrap
end

function JB.Util.isValid(...)
    for _, v in ipairs{...} do
        if not IsValid(v) then return false end
    end
    return true
end

function JB.Util.formatLine(str, size)
    --surface.SetFont(font)
    local start = 1
    local c = 1
    local endstr = ""
    local n = 0
    local lastspace = 0
    while string.len(str) > c do
        local sub = string.sub(str, start, c)
        if string.sub(str, c, c) == " " then lastspace = c end
        if surface.GetTextSize(sub) >= size then
            local sub2
            if lastspace == 0 then lastspace = c end
            if lastspace > 1 then
                sub2 = string.sub(str, start, lastspace - 1)
                c = lastspace
            else
                sub2 = string.sub(str, start, c)
            end

            endstr = endstr .. sub2 .. "\n"
            start = c + 1
            n = n + 1
        end

        c = c + 1
    end

    if start < string.len(str) then endstr = endstr .. string.sub(str, start) end
    return endstr, n
end

JB.Commands = {}
function JB.Util.addChatCommand(cmd, func)
    JB.Commands[cmd] = {
        func = func
   }
end

hook.Add("PlayerSay", "ChatCommands.Collection", function(ply, text)
    if text == "!collection" then
        ply:ChatPrint("https://steamcommunity.com/sharedfiles/filedetails/?id=1478358716")
        return ""
    end
end)

hook.Add("PlayerSay", "JBUtil.PlayerSay.ChatCommands", function(p, t)
    if p.JBNextCmd and p.JBNextCmd > CurTime() or not IsValid(p) or not t then return end
    p.JBNextCmd = CurTime() + 1 -- prevent spam
    local text = t
    if t and (string.Left(t, 1) == "!" or string.Left(t, 1) == "/" or string.Left(t, 1) == ":") then
        local tokens = string.Explode(" ", t or "", false)
        tokens[1] = string.gsub(tokens[1] or "", string.Left(tokens[1], 1) or "", "")
        if tokens and tokens[1] then
            local c = string.lower(tokens[1])
            if JB.Commands and JB.Commands[c] then
                table.remove(tokens, 1)
                JB.Commands[c].func(p, c, tokens)
                JB:DebugPrint(p:Nick() .. " ran chat command '" .. text .. "'")
                return false
            end
        end
    end
end)
