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


surface.CreateFont("JBWindowTitle", {
    font = "Arial",
    size = 18,
    weight = 800
})

surface.CreateFont("JBWindowTitleShadow", {
    font = "Arial",
    size = 18,
    weight = 800,
    blursize = 2
})

local matGradient = Material("materials/jailbreak_excl/gradient.png")
local color_white_shadow = Color(255, 255, 255, 1)
local color_gradient_top = Color(0, 0, 0, 20)
local color_gradient_bottom = Color(0, 0, 0, 120)
vgui.Register("JB.Frame.CloseButton", {
    Init = function(self) self.clr = Color(200, 0, 0, 80) end,
    OnCursorEntered = function(self) self.Hover = true end,
    OnCursorExited = function(self) self.Hover = false end,
    Paint = function(self, w, h)
        --surface.SetMaterial(self.Hover and matCloseHover or matClose)
        --surface.SetDrawColor(JB.Color.white)
        --surface.DrawTexturedRectRotated(w / 2,h / 2,32,32,0)
        if self.Hover then
            self.clr.a = Lerp(FrameTime() * 6, self.clr.a, 255)
        else
            self.clr.a = Lerp(FrameTime() * 6, self.clr.a, 60)
        end

        draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, JB.Color.black)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, self.clr)
        surface.SetDrawColor(color_gradient_bottom)
        surface.SetMaterial(matGradient)
        surface.DrawTexturedRect(2, 2, w - 4, h - 4)
    end
}, "Panel")

local PNL = {}
AccessorFunc(PNL, "title", "Title", FORCE_STRING)
function PNL:Init()
    self:SetTitle("Example title")
    self.CloseButton = vgui.Create("JB.Frame.CloseButton", self)
    self.CloseButton:SetSize(20, 20)
    self.CloseButton.OnMouseReleased = function() self:Remove() end
end

function PNL:PerformLayout()
    self.CloseButton:SetPos(self:GetWide() - self.CloseButton:GetWide() - (32 - self.CloseButton:GetWide()) / 2, (32 - self.CloseButton:GetTall()) / 2)
end

function PNL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, JB.Color.black)
    draw.RoundedBoxEx(4, 2, 2, w - 4, 28, JB.Color["#111"], true, true)
    draw.RoundedBox(6, 2, 2, w - 4, h - 4, JB.Color["#4a4a4a"], false, false, true, true)
    surface.SetDrawColor(color_gradient_top)
    surface.SetMaterial(matGradient)
    surface.DrawTexturedRectRotated(w / 2, 30 - 20 / 2, w - 4, 20, 180)
    surface.SetDrawColor(color_white_shadow)
    surface.DrawRect(2, 29, w - 4, 1)
    surface.SetDrawColor(color_gradient_bottom)
    surface.SetMaterial(matGradient)
    local h_grad = math.Clamp(h - 30 - 8, 0, 256)
    surface.DrawTexturedRectRotated(w / 2, 31 + h_grad / 2, w - 6, h_grad, 0)
end

vgui.Register("JB.Frame", PNL, "EditablePanel")
