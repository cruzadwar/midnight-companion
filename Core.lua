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
    mode = "support",
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

function ns:SetMode(mode)
    if not self.Data.Modes[mode] then
        self:Print("Modes : discovery, support, progression.")
        return
    end
    self.State.mode = mode
    self:Print("Mode d'aide : " .. self.Data.Modes[mode].label)
end

function ns:PrintQuickTip()
    self:RefreshIdentity()
    local recommendations = self:GetContextualRecommendations()
    local first = recommendations[1]
    self:Print(self:GetIdentityLine())
    self:Print((first and ("À faire maintenant : " .. first.text))
        or "À faire maintenant : reste en vie et observe la prochaine mécanique.")
end

function ns:PrintDiagnostic()
    local loaded = false
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        loaded = C_AddOns.IsAddOnLoaded("MidnightCompanion")
    elseif IsAddOnLoaded then
        loaded = IsAddOnLoaded("MidnightCompanion")
    end

    local version = "inconnue"
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        version = C_AddOns.GetAddOnMetadata("MidnightCompanion", "Version") or version
    elseif GetAddOnMetadata then
        version = GetAddOnMetadata("MidnightCompanion", "Version") or version
    end
    self:Print(string.format("DIAG | chargé=%s | version=%s | UI=%s | combat=%s",
        loaded and "oui" or "non",
        version,
        self.ShowPanel and "prête" or "absente",
        self.State.inCombat and "oui" or "non"))
    self:Print("DIAG | utilisez /mc show hors combat pour afficher le panneau.")
end

local function IsMageSpellKnown(spellID)
    if C_Spell and C_Spell.IsSpellKnown then
        return C_Spell.IsSpellKnown(spellID)
    end
    if IsSpellKnown then
        return IsSpellKnown(spellID)
    end
    return false
end

function ns:GetMageDestinations()
    self:RefreshIdentity()
    if self.State.classToken ~= "MAGE" then
        return nil, "Cette aide est réservée aux Mages."
    end
    local result = {}
    for _, entry in ipairs(self.Data.MageDestinations or {}) do
        result[#result + 1] = {
            destination = entry.destination,
            kind = entry.kind,
            available = IsMageSpellKnown(entry.spellID),
        }
    end
    return result
end

function ns:PrintMageHelp()
    local destinations, fallback = self:GetMageDestinations()
    if not destinations then
        self:Print(fallback)
        return
    end
    self:Print("Aide Mage | destinations vérifiées par l'API des sorts :")
    for _, entry in ipairs(destinations) do
        self:Print(string.format("%s %s : %s",
            entry.available and "[DISPONIBLE]" or "[NON DISPONIBLE]",
            entry.destination,
            entry.kind == "portal" and "portail pour le groupe" or "téléportation personnelle"))
    end
    self:Print("Conseil : portail avant le départ, téléportation pour le retour personnel ; les destinations absentes doivent être vérifiées en jeu.")
end

function ns:PrintTravelGuide()
    self:RefreshIdentity()
    self:Print("Guide voyage | destinations et options sûres :")
    for _, entry in ipairs(self.Data.TravelDestinations or {}) do
        self:Print(string.format("- %s (%s) : %s", entry.name, entry.location, entry.note))
    end
    if self.State.classToken == "MAGE" then
        self:Print("Mage : /mc mage détaille les téléportations et portails dont les sorts sont connus.")
        self:Print("Portail : le Mage le lance pour le groupe ; chaque joueur clique le portail pour voyager.")
        self:Print("Téléportation : retour personnel du Mage, sans clic du groupe.")
    else
        self:Print("Non-Mage : demande un portail à un Mage ; ne te présente pas comme capable de te téléporter.")
    end
    self:Print("Alternatives : pierre de foyer si liée à la destination, maître de vol ou portail de zone selon ce que ta carte propose.")
    self:Print("Aucun objet ou trajet supplémentaire n'est annoncé sans donnée vérifiable dans l'API.")
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

function ns:GetDashboardData()
    self:RefreshIdentity()
    local role = self.State.role
    local roleLabel = role == "TANK" and "Tank" or role == "HEALER" and "Soins" or role == "DAMAGER" and "DPS" or "Rôle à confirmer"
    local roleData = self.Data.Roles[role] or self.Data.Roles.NONE
    local averageItemLevel = nil
    if GetAverageItemLevel then
        local equipped = GetAverageItemLevel()
        if equipped and equipped > 0 then averageItemLevel = equipped end
    end
    local equipmentStatus = averageItemLevel
        and string.format("Niveau moyen %.1f", averageItemLevel)
        or "Non vérifiable dans cette version"
    local onboarding = role == "TANK" and "Avant de partir : prépare une mitigation pour le premier gros impact."
        or role == "HEALER" and "Avant de partir : repère ta cible prioritaire et garde un soin d'urgence."
        or role == "DAMAGER" and "Avant de partir : choisis une mécanique à respecter avant ton optimisation."
        or "Avant de partir : confirme ton rôle de groupe et lis la mécanique principale."
    return {
        identity = self:GetIdentityLine(),
        className = self.State.className or UNKNOWN,
        specName = self.State.specName or "Spécialisation inconnue",
        roleLabel = roleLabel,
        roleData = roleData,
        goal = roleData.priorities[1] or "Reste en vie et gère la mécanique principale.",
        actions = {
            roleData.priorities[1] or "Confirme ton rôle et ta priorité.",
            roleData.priorities[2] or "Prépare une réponse défensive ou utilitaire.",
            "Vérifie la mécanique principale avant de chercher l'optimisation.",
        },
        onboarding = onboarding,
        checks = {
            { label = "Équipement", value = equipmentStatus, why = "Le niveau moyen est un repère, pas un score de performance." },
            { label = "Talents", value = "À vérifier dans l'onglet Talents", why = "Aucune recommandation de patch n'est inventée." },
            { label = "Gemmes", value = "Données non vérifiables", why = "La présence et la valeur des gemmes dépendent des API et objets disponibles." },
            { label = "Enchantements", value = "Données non vérifiables", why = "L'addon ne prétend pas inspecter un enchantement absent de l'API." },
            { label = "Préparation", value = "À confirmer avant départ", why = "Une préparation utile dépend de la rencontre et du groupe." },
        },
    }
end

function ns:GetContextualRecommendations()
    local roleData = self.Data.Roles[self.State.role] or self.Data.Roles.NONE
    local modeData = self.Data.Modes[self.State.mode] or self.Data.Modes.support
    local result = {}
    local function add(priority, text)
        result[#result + 1] = { priority = priority, text = text }
    end

    if self.State.inCombat then
        add("URGENT", self.State.mode == "discovery"
            and "Regarde l'indication principale et reste en vie ; tu n'as pas besoin de tout gérer d'un coup."
            or "Mécanique d'abord : déplace-toi et reste vivant avant de chercher l'optimisation.")
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
        add("PRÉPARATION", modeData.description)
        add("PRIORITÉ", modeData.priorities[1])
        add("OBJECTIF", roleData.priorities[1])
        add("DONNÉES", "Aucune recommandation de sort ou de talent n'est inventée sans données de patch vérifiées.")
    end
    return result
end

SLASH_MIDNIGHTCOMPANION1 = "/mc"
SLASH_MIDNIGHTCOMPANION2 = "/midnightcompanion"
SlashCmdList.MIDNIGHTCOMPANION = function(message)
    local command = string.lower(strtrim(message or ""))
    if command == "show" or command == "" then
        ns:Print("Commande /mc show reçue.")
        ns:PrintQuickTip()
        if ns.ShowPanel then
            ns:ShowPanel()
        else
            ns:Print("Erreur : interface Midnight Companion absente.")
        end
    elseif command == "diag" or command == "diagnostic" or command == "status" then
        ns:PrintDiagnostic()
    elseif command == "travel" then
        ns:PrintTravelGuide()
    elseif command == "mage" then
        ns:PrintTravelGuide()
        if ns.State.classToken == "MAGE" then ns:PrintMageHelp() end
    elseif command == "toggle" then
        if ns.TogglePanel then ns:TogglePanel() end
    elseif command == "help" then
        ns:Print("/mc show - afficher les recommandations dans le chat")
        ns:Print("/mc status - confirmer le chargement et l'interface")
        ns:Print("/mc diag - alias détaillé de /mc status")
        ns:Print("/mc travel - guide de voyage pour toutes les classes")
        ns:Print("/mc mage - alias voyage, avec détail des sorts pour Mage")
        ns:Print("/mc toggle - afficher ou masquer le panneau")
        ns:Print("/midnightcompanion show - alias de /mc show")
        ns:Print("/mc reset - réinitialiser les compteurs de combat")
    elseif command == "reset" then
        ns:ResetCombat()
        ns:Print("Compteurs de combat réinitialisés.")
    elseif command == "report" then
        if ns.PrintReport then ns:PrintReport() else ns:Print("Aucun rapport disponible.") end
    elseif command == "mode" then
        local mode = string.lower(strtrim(message or ""):gsub("^mode%s*", ""))
        ns:SetMode(mode)
    elseif command == "details" then
        ns:PrintRecommendations()
    else
        ns:Print("Commande inconnue. Utilisez /mc help.")
    end
end

local startup = CreateFrame("Frame")
startup:RegisterEvent("PLAYER_LOGIN")
startup:SetScript("OnEvent", function()
    ns:RefreshIdentity()
    ns:Print("Midnight Companion est chargé. /mc show ouvre le panneau ; /mc status confirme l'état.")
end)
