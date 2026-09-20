local _, ns = ...

local panel
local lines = {}
ns.UI = ns

local function AddText(text, size, color, y)
    local line = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line:SetFont(line:GetFont(), size)
    line:SetTextColor(color[1], color[2], color[3])
    line:SetJustifyH("LEFT")
    line:SetWidth(340)
    line:SetHeight(24)
    line:SetPoint("TOPLEFT", 0, y)
    line:SetText(text)
    return line
end

local function CreatePanel()
    if panel then return end
    -- One anonymous normal frame. No secure template and no Blizzard frame mutation.
    panel = CreateFrame("Frame", nil, UIParent)
    panel:SetSize(380, 360)
    panel:SetPoint("CENTER", UIParent, "CENTER")

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.03, 0.04, 0.07, 0.96)

end

function ns:TogglePanel()
    if InCombatLockdown() then
        ns:Print("Le panneau est disponible hors combat.")
        return
    end
    CreatePanel()
    if panel:IsShown() then panel:Hide(); return end
    for _, line in ipairs(lines) do line:Hide() end
    wipe(lines)

    ns:RefreshIdentity()
    local roleData = ns.Data.Roles[ns.State.role] or ns.Data.Roles.NONE
    local function AddLine(text, size, color, y)
        local line = AddText(text, size, color, y)
        table.insert(lines, line)
    end
    AddLine("Midnight Companion", 18, { 0.44, 0.84, 1 }, -20)
    AddLine(ns:GetIdentityLine(), 14, { 1, 0.82, 0.35 }, -52)

    local y = -88
    for _, priority in ipairs(roleData.priorities) do
        AddLine("• " .. priority, 12, { 0.92, 0.92, 0.92 }, y)
        y = y - 38
    end
    AddLine("Survie : " .. roleData.survival, 12, { 1, 0.55, 0.35 }, y)
    y = y - 38
    AddLine("Équipement : " .. ns.Data.Equipment[1], 11, { 0.75, 0.82, 0.9 }, y)
    y = y - 32
    AddLine("Talents : " .. ns.Data.Talents[3], 11, { 0.75, 0.82, 0.9 }, y)
    panel:Show()
end
