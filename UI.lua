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
    panel:SetSize(430, 500)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.02, 0.03, 0.06, 0.97)
    panel:SetFrameStrata("MEDIUM")

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

    local data = ns:GetRecommendationData()
    local function AddLine(text, size, color, y)
        local line = AddText(text, size, color, y)
        table.insert(lines, line)
    end
    AddLine("Midnight Companion", 20, { 0.44, 0.84, 1 }, -20)
    AddLine(data.identity, 14, { 1, 0.82, 0.35 }, -52)
    AddLine("PRIORITÉS DE JEU", 11, { 0.45, 0.75, 0.95 }, -82)

    local y = -108
    for _, priority in ipairs(data.roleData.priorities) do
        AddLine("• " .. priority, 12, { 0.92, 0.92, 0.92 }, y)
        y = y - 38
    end
    AddLine("Survie : " .. data.roleData.survival, 12, { 1, 0.55, 0.35 }, y)
    y = y - 40
    if data.classHint then
        AddLine("Repère classe : " .. data.classHint, 11, { 0.84, 0.9, 0.96 }, y)
        y = y - 42
    end
    AddLine("ÉQUIPEMENT & TALENTS", 11, { 0.45, 0.75, 0.95 }, y)
    y = y - 26
    AddLine("• " .. data.equipment[1], 11, { 0.75, 0.82, 0.9 }, y)
    y = y - 32
    AddLine("• " .. data.equipment[2], 11, { 0.75, 0.82, 0.9 }, y)
    y = y - 32
    AddLine("• " .. data.talents[1], 11, { 0.75, 0.82, 0.9 }, y)
    y = y - 32
    AddLine("Données patch : " .. data.talents[3], 10, { 0.62, 0.68, 0.76 }, y)
    panel:Show()
end
