local _, ns = ...

local ui = {}
ns.UI = ui

local panel
local lines = {}
local open = false

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

function ui:Create()
    if panel then return end
    -- One anonymous normal frame. No secure template and no Blizzard frame mutation.
    panel = CreateFrame("Frame", nil, nil)
    panel:SetSize(380, 430)
    panel:SetPoint("CENTER", UIParent, "CENTER")

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.03, 0.04, 0.07, 0.96)

    local border = panel:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", 1, -1)
    border:SetPoint("BOTTOMRIGHT", -1, 1)
    border:SetColorTexture(0.25, 0.55, 0.75, 0.35)

end

function ui:Refresh()
    if InCombatLockdown() then return end
    self:Create()
    for _, line in ipairs(lines) do line:Hide() end
    wipe(lines)

    local state = ns.State
    local roleData = ns.Data.Roles[state.role] or ns.Data.Roles.NONE
    local identity = ns:GetIdentityLine()
    local function AddLine(text, size, color, y)
        local line = AddText(text, size, color, y)
        table.insert(lines, line)
    end
    AddLine("Midnight Companion 0.5.2", 18, { 0.44, 0.84, 1 }, -18)
    AddLine(identity, 14, { 1, 0.82, 0.35 }, -48)

    local y = -80
    for _, priority in ipairs(roleData.priorities) do
        AddLine("• " .. priority, 12, { 0.9, 0.9, 0.9 }, y)
        y = y - 42
    end
    AddLine("Survie : " .. roleData.survival, 12, { 1, 0.55, 0.35 }, y)
    y = y - 42
    AddLine("Équipement : " .. ns.Data.Equipment[1], 11, { 0.75, 0.82, 0.9 }, y)
    y = y - 34
    AddLine("Talents : " .. ns.Data.Talents[3], 11, { 0.75, 0.82, 0.9 }, y)
end

function ui:Toggle()
    if InCombatLockdown() then
        ns:Print("Panneau indisponible pendant le combat.")
        return
    end
    self:Create()
    if open then
        panel:Hide()
        open = false
    else
        self:Refresh()
        panel:Show()
        open = true
    end
end
