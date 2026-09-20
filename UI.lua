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
    panel = CreateFrame("Frame", "MidnightCompanionPanel", UIParent)
    panel:SetSize(460, 330)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(100)
    panel:SetToplevel(true)
    panel:SetAlpha(1)

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.02, 0.03, 0.06, 1)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("MIDNIGHT COMPANION")
    title:SetTextColor(0.45, 0.85, 1)
    title:Show()
end

function ns:TogglePanel()
    if InCombatLockdown() then
        ns:Print("Le panneau est disponible hors combat.")
        return
    end
    CreatePanel()
    if panel:IsShown() then
        panel:Hide()
        ns:Print("Panneau masqué.")
        return
    end
    for _, line in ipairs(lines) do line:Hide() end
    wipe(lines)

    local data = ns:GetRecommendationData()
    local function AddLine(text, size, color, y)
        local line = AddText(text, size, color, y)
        table.insert(lines, line)
    end
    AddLine("Coach de jeu actif", 16, { 0.45, 0.85, 1 }, -48)
    AddLine(data.identity, 14, { 1, 0.82, 0.35 }, -52)
    local modeData = ns.Data.Modes[ns.State.mode] or ns.Data.Modes.support
    AddLine((data.combat.inCombat and "COACHING EN COMBAT" or "PRÉPARATION")
        .. " • " .. modeData.label, 11, { 0.45, 0.75, 0.95 }, -82)

    local y = -108
    for index, recommendation in ipairs(data.recommendations) do
        if index > 1 then break end
        local color = recommendation.priority == "URGENT" and { 1, 0.35, 0.3 }
            or recommendation.priority == "DÉFENSE" and { 1, 0.65, 0.25 }
            or { 0.92, 0.92, 0.92 }
        AddLine("[" .. recommendation.priority .. "] " .. recommendation.text, 12, color, y)
        y = y - 40
    end
    AddLine("Survie : " .. data.roleData.survival, 12, { 1, 0.55, 0.35 }, y)
    y = y - 40
    if data.classHint then
        AddLine("Repère classe : " .. data.classHint, 11, { 0.84, 0.9, 0.96 }, y)
        y = y - 42
    end
    y = y - 24
    if data.combat.inCombat then
        local duration = data.combat.combatStart and (GetTime() - data.combat.combatStart) or 0
        AddLine(string.format("• En combat depuis %.0fs", duration), 11, { 1, 0.45, 0.35 }, y)
    else
        AddLine("• Hors combat : prêt pour la prochaine rencontre", 11, { 0.55, 0.85, 0.6 }, y)
    end
    AddLine("Conseil court. Tape /mc details pour le détail.", 10, { 0.62, 0.68, 0.76 }, y - 30)
    panel:Show()
    panel:Raise()
    ns:Print("Panneau Midnight Companion affiché.")
end
