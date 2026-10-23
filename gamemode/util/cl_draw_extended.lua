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


-- draws a text with a shadow font under it.

-- we will probably call this many times each frame, so let's localize a bit
local getTextSize = surface.GetTextSize
local setTextPos = surface.SetTextPos
local setTextColor = surface.SetTextColor
local setFont = surface.SetFont
local drawText = surface.DrawText
local ceil = math.ceil
-- actual function
function JB.Util.drawSimpleShadowText(text, font, x, y, color, xalign, yalign, passes)
    if not font or not x or not y or not color or not xalign or not yalign then return end
    passes = passes or 2
    text = tostring(text)
    setFont(font .. "Shadow")
    local width, height = getTextSize(text)
    if xalign == TEXT_ALIGN_CENTER then
        x = x - width / 2
    elseif xalign == TEXT_ALIGN_RIGHT then
        x = x - width
    end

    if yalign == TEXT_ALIGN_CENTER then
        y = y - height / 2
    elseif yalign == TEXT_ALIGN_BOTTOM then
        y = y - height
    end

    setTextColor(0, 0, 0, color.a)
    for _ = 1, passes do
        setTextPos(ceil(x), ceil(y))
        drawText(text)
    end

    setFont(font)
    setTextPos(ceil(x), ceil(y))
    setTextColor(color.r, color.g, color.b, color.a)
    drawText(text)
    return width, height
end
