local _, ns = ...
ns.UI = ns

local panel
local body
local buttons = {}
local activeTab = "overview"

local COLORS = {
    cyan = { 0.30, 0.86, 1.00 },
    gold = { 1.00, 0.78, 0.28 },
    text = { 0.90, 0.94, 0.98 },
    muted = { 0.52, 0.62, 0.72 },
    safe = { 0.36, 0.90, 0.62 },
}

local function Text(parent, text, size, color, width, height)
    local line = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line:SetFont(line:GetFont(), size)
    line:SetTextColor(color[1], color[2], color[3])
    line:SetJustifyH("LEFT")
    line:SetWidth(width or 420)
    line:SetHeight(height or 22)
    line:SetText(text)
    return line
end

local function AddLine(parent, text, size, color, y, height)
    local line = Text(parent, text, size, color, 448, height or 22)
    line:SetPoint("TOPLEFT", 20, y)
    return line
end

local function ClearBody()
    for _, child in ipairs({ body:GetChildren() }) do child:Hide() end
    for _, region in ipairs({ body:GetRegions() }) do region:Hide() end
end

local function CreatePanel()
    if panel then return end
    panel = CreateFrame("Frame", "MidnightCompanionPanel", UIParent)
    panel:Hide()
    panel:SetSize(560, 470)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.02, 0.03, 0.06, 1)
    local topGlow = panel:CreateTexture(nil, "BORDER")
    topGlow:SetPoint("TOPLEFT")
    topGlow:SetPoint("TOPRIGHT")
    topGlow:SetHeight(5)
    topGlow:SetColorTexture(0.30, 0.86, 1.00, 1)

    Text(panel, "MIDNIGHT COMPANION  •  TABLEAU DE BORD", 16, COLORS.cyan, 520, 26):SetPoint("TOPLEFT", 20, -16)
    body = CreateFrame("Frame", nil, panel)
    body:SetPoint("TOPLEFT", 0, -92)
    body:SetSize(560, 370)

    local tabs = {
        { id = "overview", label = "APERÇU" },
        { id = "equipment", label = "ÉQUIPEMENT" },
        { id = "talents", label = "TALENTS" },
        { id = "travel", label = "VOYAGE" },
    }
    for index, tab in ipairs(tabs) do
        local button = CreateFrame("Button", nil, panel)
        button:SetSize(126, 26)
        button:SetPoint("TOPLEFT", 18 + ((index - 1) * 132), -54)
        local label = Text(button, tab.label, 10, COLORS.muted, 120, 22)
        label:SetPoint("CENTER")
        button:SetScript("OnClick", function()
            activeTab = tab.id
            ns:RefreshPanel()
        end)
        buttons[tab.id] = button
    end
end

function ns:RefreshPanel()
    if not panel then CreatePanel() end
    ClearBody()
    local data = self:GetDashboardData()
    local y = -4
    if activeTab == "overview" then
        AddLine(body, data.identity, 14, COLORS.text, y); y = y - 28
        AddLine(body, "ONBOARDING  •  " .. data.onboarding, 11, COLORS.gold, y, 36); y = y - 48
        AddLine(body, "PROCHAIN OBJECTIF  •  " .. data.goal, 12, COLORS.cyan, y, 34); y = y - 46
        AddLine(body, "ACTIONS PRIORITAIRES", 11, COLORS.gold, y); y = y - 24
        for index = 1, 3 do
            AddLine(body, string.format("%d. %s", index, data.actions[index]), 11, COLORS.text, y, 28)
            y = y - 32
        end
        AddLine(body, "ÉTAT DE PRÉPARATION", 11, COLORS.gold, y); y = y - 24
        AddLine(body, "Équipement : " .. data.checks[1].value, 11, COLORS.safe, y); y = y - 25
        AddLine(body, "Talents / gemmes / enchantements : consulter les onglets dédiés", 11, COLORS.muted, y, 30); y = y - 40
        AddLine(body, "Pourquoi : " .. data.checks[1].why, 10, COLORS.muted, y, 32)
        AddLine(body, "Rencontres : aucune rencontre vérifiée n'est requise pour ce tableau de bord générique.", 10, COLORS.muted, -318, 28)
    elseif activeTab == "equipment" or activeTab == "talents" then
        local start = activeTab == "equipment" and 1 or 2
        local finish = activeTab == "equipment" and 1 or 4
        AddLine(body, activeTab == "equipment" and "ÉQUIPEMENT • REPÈRES" or "TALENTS, GEMMES, ENCHANTEMENTS", 14, COLORS.cyan, y)
        y = y - 34
        for index = start, finish do
            local check = data.checks[index]
            AddLine(body, check.label .. "  •  " .. check.value, 12, COLORS.text, y, 28)
            y = y - 34
            AddLine(body, "Pourquoi : " .. check.why, 10, COLORS.muted, y, 30)
            y = y - 42
        end
        AddLine(body, "Aucun score précis n'est calculé quand les données ne sont pas vérifiables.", 10, COLORS.gold, y, 34)
    else
        AddLine(body, "VOYAGE", 14, COLORS.cyan, y); y = y - 30
        AddLine(body, "Voir /mc travel pour la carte de destinations, les portails de Mage et les alternatives.", 11, COLORS.text, y, 40)
        y = y - 54
        AddLine(body, "Conseil : prépare ton retour avant le départ et demande un portail à un Mage si nécessaire.", 11, COLORS.gold, y, 40)
    end
    AddLine(body, "Données prudentes : les valeurs non vérifiables restent signalées, jamais inventées.", 10, COLORS.muted, -350, 30)
end

function ns:ShowPanel()
    if InCombatLockdown() then
        ns:Print("Le tableau de bord est disponible hors combat.")
        return
    end
    CreatePanel()
    self:RefreshPanel()
    panel:Show()
    panel:Raise()
    ns:Print("Tableau de bord Midnight Companion affiché.")
end

function ns:TogglePanel()
    CreatePanel()
    if panel:IsShown() then
        panel:Hide()
        ns:Print("Tableau de bord masqué.")
    else
        self:ShowPanel()
    end
end
