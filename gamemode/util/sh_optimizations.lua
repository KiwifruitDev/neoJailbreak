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

function JB.Util.memoize(f)
    local mem = {}
    setmetatable(mem, {
        __mode = "kv"
   })
    return function(x)
        local r = mem[x]
        if r == nil then
            r = f(x)
            mem[x] = r
        end
        return r
    end
end
