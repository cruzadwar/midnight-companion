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
