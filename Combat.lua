local _, ns = ...
local combatEvents = CreateFrame("Frame")

local function Message(text)
    ns:Print(text)
end

combatEvents:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        ns.State.inCombat = true
        ns.State.combatStart = GetTime()
        ns:ResetCombat()
        Message("Combat commencé. Priorité : mécanique et survie.")
    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.State.inCombat = false
        local duration = ns.State.combatStart and math.max(0, GetTime() - ns.State.combatStart) or 0
        Message(string.format("Rapport : %.0fs, dégâts subis %d, interruptions %d, dispels %d, morts %d.",
            duration, ns.State.damageTaken, ns.State.interrupts, ns.State.dispels, ns.State.deaths))
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, amount =
            CombatLogGetCurrentEventInfo()
        local playerGUID = UnitGUID("player")
        if destGUID == playerGUID and (subEvent == "SPELL_DAMAGE"
            or subEvent == "SWING_DAMAGE" or subEvent == "RANGE_DAMAGE") then
            ns.State.damageTaken = ns.State.damageTaken + (tonumber(amount) or 0)
        elseif destGUID == playerGUID and subEvent == "UNIT_DIED" then
            ns.State.deaths = ns.State.deaths + 1
            Message("Mort détectée : revoyez la mécanique et le timing défensif.")
        elseif sourceGUID == playerGUID and subEvent == "SPELL_INTERRUPT" then
            ns.State.interrupts = ns.State.interrupts + 1
        elseif sourceGUID == playerGUID and subEvent == "SPELL_DISPEL" then
            ns.State.dispels = ns.State.dispels + 1
        end
    end
end)

combatEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
combatEvents:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
