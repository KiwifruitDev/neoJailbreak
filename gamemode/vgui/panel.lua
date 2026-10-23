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

local PNL = {}
local color_shade = Color(255, 255, 255, 5)
local color_bg = Color(20, 20, 20)
local color_bg_weak = Color(20, 20, 20, 240)
local matGradient = Material("materials/jailbreak_excl/gradient.png")
function PNL:Paint(w, h)
    surface.SetMaterial(matGradient)
    surface.SetDrawColor(color_bg)
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetDrawColor(color_bg_weak)
    surface.DrawRect(0, 0, w, h)
    draw.RoundedBox(0, 0, 0, w, 1, color_shade)
end

vgui.Register("JB.Panel", PNL, "EditablePanel")
