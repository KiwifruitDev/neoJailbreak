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

local matEdge = Material("materials/jailbreak_excl/button_edge.png")
local matMid = Material("materials/jailbreak_excl/button_middle.png")
surface.CreateFont("JBButton", {
    font = JB.Config.font,
    size = 14,
    weight = 700,
})

surface.CreateFont("JBButtonShadow", {
    font = JB.Config.font,
    size = 14,
    weight = 700,
    blursize = 2,
})

local PNL = {}
AccessorFunc(PNL, "text", "Text", FORCE_STRING)
function PNL:Init()
    self:SetText("Example text")
    self.color = Color(200, 200, 200)
end

function PNL:OnCursorEntered()
    self.Hover = true
end

function PNL:OnCursorExited()
    self.Hover = false
end

function PNL:Paint(w, h)
    if self.Hover then
        self.color.r = math.Approach(self.color.r, 255, FrameTime() * 600)
        self.color.g = math.Approach(self.color.g, 255, FrameTime() * 600)
        self.color.b = math.Approach(self.color.b, 255, FrameTime() * 600)
    else
        self.color.r = math.Approach(self.color.r, 180, FrameTime() * 400)
        self.color.g = math.Approach(self.color.g, 180, FrameTime() * 400)
        self.color.b = math.Approach(self.color.b, 180, FrameTime() * 400)
    end

    surface.SetDrawColor(Color(self.color.r * .8, self.color.g * .8, self.color.b * .8))
    surface.SetMaterial(matEdge)
    surface.DrawTexturedRectRotated(32 / 2, h / 2, 32, 32, 0)
    surface.DrawTexturedRectRotated(w - 32 / 2, h / 2, 32, 32, 180)
    surface.SetMaterial(matMid)
    surface.DrawTexturedRectRotated(w / 2, h / 2, w - 64, 32, 0)
    draw.SimpleText(self:GetText(), "JBButtonShadow", w / 2, h / 2, JB.Color.black, 1, 1)
    draw.SimpleText(self:GetText(), "JBButtonShadow", w / 2, h / 2, JB.Color.black, 1, 1)
    draw.SimpleText(self:GetText(), "JBButton", w / 2, h / 2, self.color, 1, 1)
end

vgui.Register("JB.Button", PNL, "Panel")
