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

--local color_text = Color(230,230,230,200)
local frame
local randomHealed = {"All patched up and ready to go!", "Thank you for doing business with me!", "You're all set, don't tell anyone you saw me.", "You're healed up. This never happened, head out now!", "Body armor is in place and you're healed up. You're free to go!"}
function JB.MENU_HEAL()
    if IsValid(frame) then frame:Remove() end
    frame = vgui.Create("JB.Frame")
    frame:SetTitle("Detective Dickhead")
    local yBottom = 30
    frame:SetWide(500)
    local lbl = Label("Purchase 100% Health/Armor for 15 Pennies?", frame)
    lbl:SetFont("JBLarge")
    lbl:SetColor(JB.Color["#EEE"])
    lbl:SizeToContents()
    lbl:SetPos(15, yBottom + 15)
    yBottom = lbl.y + lbl:GetTall()
    local function addButton(name, click)
        local btn = frame:Add("JB.Button")
        btn:SetPos(15, yBottom + 15)
        btn:SetSize(frame:GetWide() - 30, 32)
        btn:SetText(name)
        btn.OnMouseReleased = click
        yBottom = btn.y + btn:GetTall()
    end

    if LocalPlayer().PS_Points >= 15 then
        local function SetHP(hp)
            LocalPlayer():ChatPrint(table.Random(randomHealed))
            net.Start("sethealth")
            net.WriteInt(hp, 32)
            net.SendToServer()
        end

        addButton("Yes, make purchase!", function()
            frame:Remove()
            SetHP(100)
        end)

        addButton("No, I want to buy a weapon.", function() frame:Remove() end)
    else
        addButton("No, I don't have enough pennies! I want to buy a weapon.", function() frame:Remove() end)
    end

    frame:SetTall(yBottom + 15)
    frame:Center()
    frame:MakePopup()
end
