local addonName, ns = ...
ns = ns or {}
MidnightCompanion = ns

local frame = CreateFrame("Frame")
ns.Events = frame
ns.State = {
    classToken = nil,
    className = nil,
    specID = nil,
    specName = nil,
    role = "NONE",
    inCombat = false,
    combatStart = nil,
    damageTaken = 0,
    deaths = 0,
    interrupts = 0,
    dispels = 0,
    mechanics = 0,
}

local function SafeRole()
    local role = UnitGroupRolesAssigned("player")
    if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
        return role
    end
    return "NONE"
end

function ns:RefreshIdentity()
    local className, classToken = UnitClass("player")
    local specID, specName = nil, nil
    local index = GetSpecialization()
    if index then
        specID, specName = GetSpecializationInfo(index)
    end
    self.State.className = className or UNKNOWN
    self.State.classToken = classToken
    self.State.specID = specID
    self.State.specName = specName
    self.State.role = SafeRole()
    if self.UI and self.UI.Refresh then
        self.UI:Refresh()
    end
end

function ns:GetIdentityLine()
    local state = self.State
    local spec = state.specName or "spécialisation inconnue"
    local role = state.role == "NONE" and "rôle non assigné" or state.role
    return string.format("%s - %s (%s)", state.className or UNKNOWN, spec, role)
end

function ns:ResetCombat()
    self.State.damageTaken = 0
    self.State.deaths = 0
    self.State.interrupts = 0
    self.State.dispels = 0
    self.State.mechanics = 0
end

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff70d6ffMidnight Companion|r: " .. message)
end

SLASH_MIDNIGHTCOMPANION1 = "/mc"
SlashCmdList.MIDNIGHTCOMPANION = function(message)
    local command = string.lower(strtrim(message or ""))
    if command == "reset" then
        ns:ResetCombat()
        ns:Print("Statistiques de combat réinitialisées.")
    elseif command == "show" or command == "" then
        if ns.UI then ns.UI:Toggle() end
    elseif command == "help" then
        ns:Print("/mc show - afficher ou masquer le panneau")
        ns:Print("/mc reset - réinitialiser les statistiques du combat")
    else
        ns:Print("Commande inconnue. Utilisez /mc help.")
    end
end

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD"
        or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
        ns:RefreshIdentity()
    end
end)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
