local _, ns = ...

local ui = {}
ns.UI = ui

local panel
local content

local function AddText(text, size, color, y)
    local line = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line:SetFont(line:GetFont(), size)
    line:SetTextColor(color[1], color[2], color[3])
    line:SetJustifyH("LEFT")
    line:SetWidth(340)
    line:SetHeight(24)
    line:SetPoint("TOPLEFT", 0, y)
    line:SetText(text)
    return line
end

function ui:Create()
    if panel then return end
    -- Plain anonymous frame: no secure template, no Blizzard frame mutation.
    panel = CreateFrame("Frame", nil, UIParent)
    panel:SetSize(380, 430)
    panel:SetPoint("CENTER")
    panel:SetClampedToScreen(true)

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.03, 0.04, 0.07, 0.96)

    local border = panel:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", 1, -1)
    border:SetPoint("BOTTOMRIGHT", -1, 1)
    border:SetColorTexture(0.25, 0.55, 0.75, 0.35)

    content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 18, -18)
    content:SetSize(344, 394)
    panel:Hide()
end

function ui:Refresh()
    if InCombatLockdown() then return end
    self:Create()
    for _, child in ipairs({ content:GetChildren() }) do child:Hide() end

    local state = ns.State
    local roleData = ns.Data.Roles[state.role] or ns.Data.Roles.NONE
    local identity = ns:GetIdentityLine()
    AddText("Midnight Companion 0.5.0", 18, { 0.44, 0.84, 1 }, 0)
    AddText(identity, 14, { 1, 0.82, 0.35 }, -30)

    local y = -62
    for _, priority in ipairs(roleData.priorities) do
        AddText("• " .. priority, 12, { 0.9, 0.9, 0.9 }, y)
        y = y - 42
    end
    AddText("Survie : " .. roleData.survival, 12, { 1, 0.55, 0.35 }, y)
    y = y - 42
    AddText("Équipement : " .. ns.Data.Equipment[1], 11, { 0.75, 0.82, 0.9 }, y)
    y = y - 34
    AddText("Talents : " .. ns.Data.Talents[3], 11, { 0.75, 0.82, 0.9 }, y)
end

function ui:Toggle()
    if InCombatLockdown() then
        ns:Print("Panneau indisponible pendant le combat.")
        return
    end
    self:Create()
    if panel:IsShown() then
        panel:Hide()
    else
        self:Refresh()
        panel:Show()
    end
end
