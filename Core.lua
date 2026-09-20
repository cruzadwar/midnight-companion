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
    encounterName = nil,
    challengeActive = false,
    lastReport = nil,
    history = {},
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
    self.State.mechanics = 0
end

function ns:PrintRecommendations()
    self:RefreshIdentity()
    local roleData = self.Data.Roles[self.State.role] or self.Data.Roles.NONE
    local classHint = self.Data.ClassHints[self.State.classToken]
    self:Print(self:GetIdentityLine())
    for _, priority in ipairs(roleData.priorities) do
        self:Print("Priorité : " .. priority)
    end

    self:Print("Survie : " .. roleData.survival)
    if classHint then self:Print("Classe : " .. classHint) end
    self:Print("Équipement : " .. self.Data.Equipment[1])
    self:Print("Talents : " .. self.Data.Talents[3])
    if self.State.lastReport then
        self:Print(string.format("Dernier combat : %s", self.State.lastReport.summary))
    end
end

function ns:GetRecommendationData()
    self:RefreshIdentity()
    local recommendations = self:GetContextualRecommendations()
    return {
        identity = self:GetIdentityLine(),
        role = self.State.role,
        roleData = self.Data.Roles[self.State.role] or self.Data.Roles.NONE,
        classHint = self.Data.ClassHints[self.State.classToken],
        equipment = self.Data.Equipment,
        talents = self.Data.Talents,
        combat = self.State,
        recommendations = recommendations,
    }
end

function ns:GetContextualRecommendations()
    local roleData = self.Data.Roles[self.State.role] or self.Data.Roles.NONE
    local result = {}
    local function add(priority, text)
        result[#result + 1] = { priority = priority, text = text }
    end

    if self.State.inCombat then
        add("URGENT", "Mécanique d'abord : déplace-toi et reste vivant avant de chercher l'optimisation.")
        if self.State.role == "HEALER" then
            add("SOINS", "Stabilise les alliés en danger, puis reprends ton cycle.")
        elseif self.State.role == "TANK" then
            add("DÉFENSE", "Garde une mitigation ou une réponse défensive pour le prochain pic.")
        else
            add("DPS", "Conserve ton uptime uniquement depuis une position sûre.")
        end
        if self.State.encounterName then
            add("RENCONTRE", "Rencontre active : " .. self.State.encounterName)
        end
    else
        add("PRÉPARATION", "Vérifie ta position, tes consommables et tes raccourcis avant d'engager.")
        add("OBJECTIF", roleData.priorities[1])
        add("DONNÉES", "Aucune recommandation de sort ou de talent n'est inventée sans données de patch vérifiées.")
    end
    return result
end

SLASH_MIDNIGHTCOMPANION1 = "/mc"
SlashCmdList.MIDNIGHTCOMPANION = function(message)
    local command = string.lower(strtrim(message or ""))
    if command == "show" or command == "" then
        ns:PrintRecommendations()
        if ns.TogglePanel then ns:TogglePanel() end
    elseif command == "help" then
        ns:Print("/mc show - afficher les recommandations dans le chat")
        ns:Print("/mc reset - réinitialiser les compteurs de combat")
    elseif command == "reset" then
        ns:ResetCombat()
        ns:Print("Compteurs de combat réinitialisés.")
    elseif command == "report" then
        if ns.PrintReport then ns:PrintReport() else ns:Print("Aucun rapport disponible.") end
    else
        ns:Print("Commande inconnue. Utilisez /mc help.")
    end
end
