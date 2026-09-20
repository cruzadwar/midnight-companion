local _, ns = ...
local ui = {}
ns.UI = ui

local panel
local body
local alerts
local report

local function FontString(parent, size, color)
    local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetFont(text:GetFont(), size)
    text:SetTextColor(unpack(color or { 1, 1, 1 }))
    text:SetJustifyH("LEFT")
    return text
end

local function AddLines(container, lines, color)
    for _, line in ipairs(lines) do
        local text = FontString(container, 12, color)
        text:SetText("• " .. line)
        text:SetWordWrap(true)
        text:SetWidth(340)
        text:SetHeight(26)
        text:SetPoint("TOPLEFT", 0, -((container.lineCount or 0) * 25))
        container.lineCount = (container.lineCount or 0) + 1
    end
end

local function Clear(container)
    for _, child in ipairs({ container:GetChildren() }) do child:Hide() end
    container.lineCount = 0
end

function ui:Create()
    panel = CreateFrame("Frame", "MidnightCompanionPanel", UIParent, "BackdropTemplate")
    panel:SetSize(390, 520)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(frame)
        if not InCombatLockdown() then
            frame:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(frame)
        if not InCombatLockdown() then
            frame:StopMovingOrSizing()
        end
    end)
    panel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0.03, 0.04, 0.07, 0.96)

    local title = FontString(panel, 18, { 0.44, 0.84, 1 })
    title:SetText("Midnight Companion")
    title:SetPoint("TOPLEFT", 18, -16)
    local hint = FontString(panel, 11, { 0.65, 0.68, 0.74 })
    hint:SetText("Glissez le panneau pour le déplacer • /mc pour le masquer")
    hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)

    body = CreateFrame("Frame", nil, panel)
    body:SetPoint("TOPLEFT", 18, -62)
    body:SetSize(350, 200)
    alerts = CreateFrame("Frame", nil, panel)
    alerts:SetPoint("TOPLEFT", 18, -270)
    alerts:SetSize(350, 80)
    report = CreateFrame("Frame", nil, panel)
    report:SetPoint("TOPLEFT", 18, -365)
    report:SetSize(350, 140)
    panel:Hide()
end

function ui:Refresh()
    if not panel then self:Create() end
    Clear(body)
    local identity = FontString(body, 14, { 1, 0.82, 0.35 })
    identity:SetText(ns:GetIdentityLine())
    identity:SetHeight(25)
    identity:SetWidth(350)
    identity:SetPoint("TOPLEFT")
    body.lineCount = 1

    local roleData = ns.Data.Roles[ns.State.role] or ns.Data.Roles.NONE
    AddLines(body, roleData.priorities, { 0.9, 0.9, 0.9 })
    local survival = FontString(body, 12, { 1, 0.55, 0.35 })
    survival:SetText("Survie : " .. roleData.survival)
    survival:SetWidth(350)
    survival:SetHeight(30)
    survival:SetPoint("TOPLEFT", 0, -((body.lineCount or 0) * 25) - 4)
    if panel:IsShown() then self:BuildReport() end
end

function ui:AddAlert(message)
    if not alerts then return end
    local text = FontString(alerts, 12, { 1, 0.35, 0.3 })
    text:SetText("Alerte : " .. message)
    text:SetWidth(350)
    text:SetHeight(35)
    text:SetPoint("TOPLEFT", 0, -((alerts.lineCount or 0) * 35))
    alerts.lineCount = (alerts.lineCount or 0) + 1
    if alerts.lineCount > 2 then
        local first = alerts:GetChildren()
        if first then first:Hide() end
    end
end

function ui:BuildReport()
    if not report then return end
    Clear(report)
    local state = ns.State
    local duration = state.combatStart and math.max(0, GetTime() - state.combatStart) or 0
    local title = FontString(report, 14, { 0.44, 0.84, 1 })
    title:SetText("Rapport post-combat")
    title:SetPoint("TOPLEFT")
    report.lineCount = 1
    AddLines(report, {
        string.format("Durée : %.0fs • dégâts subis : %d", duration, state.damageTaken),
        string.format("Interruption(s) : %d • dispel(s) : %d", state.interrupts, state.dispels),
        state.deaths > 0 and "Priorité : identifier la mécanique ayant causé la mort."
            or "Priorité : conserver la même discipline de mouvement.",
        "Équipement : " .. ns.Data.Equipment[1],
        "Talents : " .. ns.Data.Talents[3],
    }, { 0.82, 0.88, 0.92 })
end

function ui:Toggle()
    if not panel then self:Create() end
    if panel:IsShown() then panel:Hide() else self:Refresh(); panel:Show() end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    ns.UI:Create()
    ns:RefreshIdentity()
end)
