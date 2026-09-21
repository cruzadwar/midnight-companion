local addonName, ns = ...
ns.Data = ns.Data or {}

-- Keep patch-sensitive facts out of the core. Add verified entries here as
-- Midnight data becomes available; unknown entries intentionally stay empty.
ns.Data.Roles = {
    TANK = {
        priorities = {
            "Keep active mitigation available before predictable tank damage.",
            "Plan a defensive cooldown for the next dangerous mechanic.",
            "Face enemies away from the group and keep positioning stable.",
        },
        survival = "Watch your health, active mitigation uptime, and healer range.",
    },
    HEALER = {
        priorities = {
            "Stabilize players in danger before attempting damage.",
            "Pre-position for the next mechanic and preserve an emergency cooldown.",
            "Avoid overhealing when movement or dispels are the next priority.",
        },
        survival = "Watch your mana, movement, and the health of players in range.",
    },
    DAMAGER = {
        priorities = {
            "Handle the mechanic first; resume your rotation after you are safe.",
            "Use defensives before avoidable damage rather than after it lands.",
            "Keep uptime without standing in dangerous areas.",
        },
        survival = "Watch your health, incoming damage, and movement requirements.",
    },
    NONE = {
        priorities = {
            "Join a group to enable role-aware coaching.",
            "Use the character and spellbook panels to review your current setup.",
        },
        survival = "Survival coaching becomes role-aware once your group role is known.",
    },
}

ns.Data.RoleText = {
    fr = {
        DAMAGER = {"Gère la mécanique avant de reprendre ta rotation.", "Utilise une défense avant les dégâts évitables.", "Garde ton interruption ou utilitaire prêt.", "Reste en vie et reprends ton cycle depuis une position sûre."},
        TANK = {"Garde une mitigation pour le prochain gros impact.", "Prépare une défense autour de la mécanique dangereuse.", "Oriente les ennemis loin du groupe.", "Surveille ta vie, ta mitigation et la portée des soins."},
        HEALER = {"Stabilise les alliés avant de chercher à faire des dégâts.", "Prépare un soin d'urgence pour la prochaine mécanique.", "Garde ta portée et évite le déplacement inutile.", "Surveille les cibles en danger, ta mana et ton placement."},
        NONE = {"Choisis DPS, Tank ou Soins dans l'outil de groupe.", "Lis la mécanique principale avant de partir.", "Demande de l'aide si le rôle reste incertain.", "Le coaching devient plus précis après le choix du rôle."},
    },
    en = {
        DAMAGER = {"Handle the mechanic before resuming your rotation.", "Use a defensive before avoidable damage.", "Keep your interrupt or utility ready.", "Stay alive and resume your cycle from a safe position."},
        TANK = {"Keep mitigation for the next heavy hit.", "Plan a defensive around the dangerous mechanic.", "Face enemies away from the group.", "Watch health, mitigation and healer range."},
        HEALER = {"Stabilize allies before looking for damage.", "Keep an emergency heal for the next mechanic.", "Stay in range and avoid needless movement.", "Watch endangered players, mana and positioning."},
        NONE = {"Choose DPS, Tank or Healer in the group tool.", "Read the main mechanic before leaving.", "Ask for help if the role is still unclear.", "Coaching becomes more precise after choosing a role."},
    },
}

ns.Data.Classes = {
    DEATHKNIGHT = true, DEMONHUNTER = true, DRUID = true, EVOKER = true,
    HUNTER = true, MAGE = true, MONK = true, PALADIN = true,
    PRIEST = true, ROGUE = true, SHAMAN = true, WARLOCK = true,
    WARRIOR = true,
}

ns.Data.Equipment = {
    "Compare upgrades by item level and the stats your current spec values.",
    "Check that equipped items have available sockets, enchants, and gems where applicable.",
    "Use the character panel for exact item and stat decisions; this addon does not simulate gear.",
}

ns.Data.Talents = {
    "Review talents after a role, dungeon, or encounter change.",
    "Prefer verified encounter guides or in-game tooltips for patch-specific talent choices.",
    "No talent is recommended until a verified Midnight data entry is added.",
}

ns.Data.Modes = {
    discovery = {
        label = "Découverte",
        description = "Explique le jeu simplement, sans jargon ni pression.",
        priorities = {
            "Observe la mécanique et suis l'indication la plus importante.",
            "Reste en vie et aide le groupe ; la performance viendra ensuite.",
        },
    },
    support = {
        label = "Accompagnement",
        description = "Une priorité claire à la fois, avec des conseils courts.",
        priorities = {
            "Choisis une seule amélioration pour la prochaine tentative.",
            "Utilise une défense ou un outil de groupe avant le danger prévisible.",
        },
    },
    progression = {
        label = "Progression",
        description = "Relie rôle, placement, survie et objectifs de rencontre.",
        priorities = {
            "Corrige d'abord la mécanique qui coûte une tentative.",
            "Prépare ton prochain temps de recharge autour du moment dangereux.",
        },
    },
}

-- These are deliberately non-rotational prompts. They remain useful without
-- pretending to know a patch-specific build, encounter, or spell priority.
ns.Data.ClassHints = {
    DEATHKNIGHT = "Anticipe les dégâts entrants et garde une ressource défensive pour les moments dangereux.",
    DEMONHUNTER = "Priorise le placement et la mobilité : une mécanique évitée vaut mieux qu'une reprise d'uptime.",
    DRUID = "Adapte ta forme et ton utilitaire au besoin du groupe avant de chercher la performance brute.",
    EVOKER = "Planifie tes déplacements et tes temps de recharge autour des fenêtres de portée du groupe.",
    HUNTER = "Préserve ta mobilité et ton utilitaire ; ne sacrifie pas une mécanique pour quelques secondes d'uptime.",
    MAGE = "Prépare tes outils de mobilité et de défense avant les phases où le déplacement est obligatoire.",
    MONK = "Coordonne mobilité, utilitaire et défenses avec le rythme des dégâts plutôt qu'en réaction tardive.",
    PALADIN = "Garde un outil de soutien disponible pour le groupe et annonce les défenses importantes.",
    PRIEST = "Surveille les cibles prioritaires et garde un outil d'urgence pour les dégâts imprévus.",
    ROGUE = "Utilise ta mobilité et tes défenses pour gérer les mécaniques sans perdre le contrôle du rythme.",
    SHAMAN = "Conserve ton utilitaire pour les moments où il change réellement l'issue d'une mécanique.",
    WARLOCK = "Planifie ton déplacement et tes défenses avant les phases qui interrompent ton cycle.",
    WARRIOR = "Entretiens ton positionnement et tes défenses ; la régularité est plus importante qu'une prise de risque.",
}

-- IDs are checked at runtime. A changed or unknown spell is shown as
-- unavailable instead of being presented as a usable destination.
ns.Data.MageDestinations = {
    { destination = "Stormwind", spellID = 3561, kind = "teleport" },
    { destination = "Orgrimmar", spellID = 3567, kind = "teleport" },
    { destination = "Portail : Stormwind", spellID = 10059, kind = "portal" },
    { destination = "Portail : Orgrimmar", spellID = 11417, kind = "portal" },
}

ns.Data.TravelDestinations = {
    { name = "Stormwind", location = "Royaumes de l'Est", note = "Capitale de l'Alliance." },
    { name = "Orgrimmar", location = "Kalimdor", note = "Capitale de la Horde." },
    { name = "Zone de départ ou hub courant", location = "Selon l'extension et le personnage", note = "Vérifier la carte et le maître de vol." },
}

ns.Locale = (GetLocale and GetLocale() or "enUS")
ns.Locale = (ns.Locale == "frFR" or ns.Locale == "frBE" or ns.Locale == "frCA") and "fr" or "en"
ns.Data.Text = {
    fr = {
        dashboard = "TABLEAU DE BORD", overview = "APERÇU", equipment = "ÉQUIPEMENT", talents = "TALENTS", travel = "VOYAGE",
        onboarding = "AVANT DE PARTIR", during = "PENDANT LE COMBAT", after = "APRÈS L'ESSAI",
        goal = "PROCHAIN OBJECTIF", actions = "ACTIONS PRIORITAIRES", why = "POURQUOI",
        unknown = "non vérifiable", generic = "Aucune rencontre vérifiée : gère la mécanique visible et reste en vie.",
        safe = "Priorité : évite les dégâts, puis reprends ton activité.",
        noData = "Donnée non vérifiable dans cette version.",
        details = "Détails : /mc details", travelHint = "Voyage : /mc travel",
    },
    en = {
        dashboard = "CHARACTER DASHBOARD", overview = "OVERVIEW", equipment = "GEAR", talents = "TALENTS", travel = "TRAVEL",
        onboarding = "BEFORE YOU GO", during = "DURING COMBAT", after = "AFTER THE TRY",
        goal = "NEXT GOAL", actions = "PRIORITY ACTIONS", why = "WHY",
        unknown = "not verifiable", generic = "No verified encounter: handle the visible mechanic and stay alive.",
        safe = "Priority: avoid damage, then resume your activity.",
        noData = "Data is not verifiable in this version.",
        details = "Details: /mc details", travelHint = "Travel: /mc travel",
    },
}

function ns:T(key)
    local language = ns.Data.Text[ns.Locale] or ns.Data.Text.en
    return language[key] or ns.Data.Text.en[key] or key
end
