local addonName, ns = ...
ns = ns or {}
MidnightCompanion = ns

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
end

function ns:GetIdentityLine()
    local state = self.State
    local spec = state.specName or "spécialisation inconnue"
    local role = state.role == "NONE" and "rôle non assigné" or state.role
    return string.format("%s - %s (%s)", state.className or UNKNOWN, spec, role)
end

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff70d6ffMidnight Companion|r: " .. message)
end

function ns:ResetCombat()
    self.State.damageTaken = 0
    self.State.deaths = 0
    self.State.interrupts = 0
    self.State.dispels = 0
end

function ns:PrintRecommendations()
    self:RefreshIdentity()
    local roleData = self.Data.Roles[self.State.role] or self.Data.Roles.NONE
    self:Print(self:GetIdentityLine())
    for _, priority in ipairs(roleData.priorities) do
        self:Print("Priorité : " .. priority)
    end

    self:Print("Survie : " .. roleData.survival)
    self:Print("Équipement : " .. self.Data.Equipment[1])
    self:Print("Talents : " .. self.Data.Talents[3])
end

SLASH_MIDNIGHTCOMPANION1 = "/mc"
SlashCmdList.MIDNIGHTCOMPANION = function(message)
    local command = string.lower(strtrim(message or ""))
    if command == "show" or command == "" then
        ns:PrintRecommendations()
    elseif command == "help" then
        ns:Print("/mc show - afficher les recommandations dans le chat")
        ns:Print("/mc reset - réinitialiser les compteurs de combat")
    elseif command == "reset" then
        ns:ResetCombat()
        ns:Print("Compteurs de combat réinitialisés.")
    else
        ns:Print("Commande inconnue. Utilisez /mc help.")
    end
end
