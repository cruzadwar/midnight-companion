local _, ns = ...

local panel
local lines = {}
ns.UI = ns

local COLORS = {
    cyan = { 0.30, 0.86, 1.00 },
    gold = { 1.00, 0.78, 0.28 },
    text = { 0.90, 0.94, 0.98 },
    muted = { 0.52, 0.62, 0.72 },
    danger = { 1.00, 0.34, 0.30 },
    safe = { 0.36, 0.90, 0.62 },
}

local function AddText(text, size, color, y)
    local line = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line:SetFont(line:GetFont(), size)
    line:SetTextColor(color[1], color[2], color[3])
    line:SetJustifyH("LEFT")
    line:SetWidth(420)
    line:SetHeight(24)
    line:SetPoint("TOPLEFT", 24, y)
    line:SetText(text)
    return line
end

local function CreatePanel()
    if panel then return end
    panel = CreateFrame("Frame", "MidnightCompanionPanel", UIParent)
    panel:Hide()
    panel:SetSize(500, 360)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(100)
    panel:SetToplevel(true)
    panel:SetAlpha(1)

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.02, 0.03, 0.06, 1)

    local topGlow = panel:CreateTexture(nil, "BORDER")
    topGlow:SetPoint("TOPLEFT")
    topGlow:SetPoint("TOPRIGHT")
    topGlow:SetHeight(5)
    topGlow:SetColorTexture(0.30, 0.86, 1.00, 1)
    local bottomGlow = panel:CreateTexture(nil, "BORDER")
    bottomGlow:SetPoint("BOTTOMLEFT")
    bottomGlow:SetPoint("BOTTOMRIGHT")
    bottomGlow:SetHeight(2)
    bottomGlow:SetColorTexture(1.00, 0.78, 0.28, 0.9)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("MIDNIGHT COMPANION")
    title:SetTextColor(unpack(COLORS.cyan))
    title:Show()
end

function ns:ShowPanel()
    if InCombatLockdown() then
        ns:Print("Le panneau est disponible hors combat.")
        return
    end
    CreatePanel()
    for _, line in ipairs(lines) do line:Hide() end
    wipe(lines)

    local data = ns:GetRecommendationData()
    local function AddLine(text, size, color, y)
        local line = AddText(text, size, color, y)
        table.insert(lines, line)
    end
    AddLine("COACH DE JEU  •  " .. (data.combat.inCombat and "ACTIF" or "PRÊT"), 11, COLORS.gold, -48)
    AddLine(data.identity, 14, COLORS.text, -76)
    local modeData = ns.Data.Modes[ns.State.mode] or ns.Data.Modes.support
    AddLine((data.combat.inCombat and "COACHING EN COMBAT" or "PRÉPARATION")
        .. " • " .. modeData.label, 11, { 0.45, 0.75, 0.95 }, -82)

    local y = -108
    local recommendations = data.recommendations
    if #recommendations == 0 then
        recommendations = {
            {
                priority = "COACH",
                text = "Aucune rencontre vérifiée : reste en vie, gère la mécanique visible, puis reprends ton activité.",
            },
        }
    end
    for index, recommendation in ipairs(recommendations) do
        if index > 1 then break end
        local color = recommendation.priority == "URGENT" and COLORS.danger
            or recommendation.priority == "DÉFENSE" and COLORS.gold
            or COLORS.text
        AddLine("[" .. recommendation.priority .. "] " .. recommendation.text, 12, color, y)
        y = y - 40
    end
    AddLine("SURVIE  •  " .. data.roleData.survival, 11, COLORS.safe, y)
    y = y - 40
    if data.classHint then
        AddLine("CLASSE  •  " .. data.classHint, 11, COLORS.text, y)
        y = y - 42
    end
    y = y - 24
    if data.combat.inCombat then
        local duration = data.combat.combatStart and (GetTime() - data.combat.combatStart) or 0
        AddLine(string.format("• En combat depuis %.0fs", duration), 11, COLORS.danger, y)
    else
        AddLine("• Hors combat : prêt pour la prochaine rencontre", 11, COLORS.safe, y)
    end
    AddLine("Conseil court  •  /mc details pour approfondir", 10, COLORS.muted, y - 30)
    panel:Show()
    panel:Raise()
    ns:Print("Panneau Midnight Companion affiché.")
end

function ns:TogglePanel()
    CreatePanel()
    if panel:IsShown() then
        panel:Hide()
        ns:Print("Panneau masqué.")
        return
    end
    self:ShowPanel()
end
