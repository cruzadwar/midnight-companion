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
