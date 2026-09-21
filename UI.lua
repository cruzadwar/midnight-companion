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
    panel:SetSize(400, 330)
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

    Text(panel, "MIDNIGHT COMPANION  •  " .. ns:T("dashboard"), 13, COLORS.cyan, 370, 24):SetPoint("TOPLEFT", 16, -14)
    body = CreateFrame("Frame", nil, panel)
    body:SetPoint("TOPLEFT", 0, -92)
    body:SetSize(400, 240)

    local tabs = {
        { id = "overview", label = ns:T("overview") },
        { id = "equipment", label = ns:T("equipment") },
        { id = "talents", label = ns:T("talents") },
        { id = "travel", label = ns:T("travel") },
    }
    for index, tab in ipairs(tabs) do
        local button = CreateFrame("Button", nil, panel)
        button:SetSize(88, 24)
        button:SetPoint("TOPLEFT", 12 + ((index - 1) * 94), -45)
        local label = Text(button, tab.label, 8, COLORS.muted, 86, 20)
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
    local y = -2
    if activeTab == "overview" then
        AddLine(body, data.identity, 11, COLORS.text, y); y = y - 23
        AddLine(body, data.context, 9, COLORS.muted, y); y = y - 22
        AddLine(body, ns:T("onboarding") .. "  •  " .. data.onboarding, 9, COLORS.gold, y, 28); y = y - 34
        AddLine(body, ns:T("goal") .. "  •  " .. data.goal, 10, COLORS.cyan, y, 30); y = y - 37
        AddLine(body, "1. " .. data.actions[1], 9, COLORS.text, y, 24); y = y - 25
        AddLine(body, "2. " .. data.actions[2], 9, COLORS.text, y, 24); y = y - 25
        AddLine(body, "3. " .. data.actions[3], 9, COLORS.text, y, 24); y = y - 30
        AddLine(body, ns:T("during") .. "  •  " .. data.localizedSurvival, 8, COLORS.safe, y, 24); y = y - 25
        AddLine(body, ns:T("after") .. "  •  " .. (ns.Locale == "fr" and "Note ce qui t'a touché et corrige une seule chose." or "Note what hit you and fix one thing."), 8, COLORS.muted, y, 24); y = y - 25
        AddLine(body, ns:T("why") .. "  •  " .. data.checks[1].why, 8, COLORS.muted, y, 24)
        AddLine(body, ns:T("generic"), 8, COLORS.muted, -228, 22)
    elseif activeTab == "equipment" or activeTab == "talents" then
        local start = activeTab == "equipment" and 1 or 2
        local finish = activeTab == "equipment" and 1 or 4
        AddLine(body, activeTab == "equipment" and ns:T("equipment") or ns:T("talents"), 12, COLORS.cyan, y)
        y = y - 34
        for index = start, finish do
            local check = data.checks[index]
            AddLine(body, check.label .. "  •  " .. check.value, 12, COLORS.text, y, 28)
            y = y - 34
            AddLine(body, ns:T("why") .. " : " .. check.why, 8, COLORS.muted, y, 26)
            y = y - 42
        end
        AddLine(body, ns:T("noData"), 9, COLORS.gold, y, 26)
    else
        AddLine(body, ns:T("travel"), 12, COLORS.cyan, y); y = y - 28
        AddLine(body, ns:T("travelHint"), 9, COLORS.text, y, 34)
        y = y - 54
        AddLine(body, ns.Locale == "fr" and "Conseil : prépare ton retour et demande un portail à un Mage." or "Tip: plan your return and ask a Mage for a portal.", 9, COLORS.gold, y, 34)
    end
    AddLine(body, ns:T("noData"), 8, COLORS.muted, -228, 22)
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
