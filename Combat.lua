local _, ns = ...
local combat = CreateFrame("Frame")
ns.Combat = combat

local function CombatMessage(message)
    if ns.UI and ns.UI.AddAlert then
        ns.UI:AddAlert(message)
    end
end

combat:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        ns.State.inCombat = true
        ns.State.combatStart = GetTime()
        ns:ResetCombat()
        CombatMessage("Combat commencé : priorité à la mécanique et à la survie.")
        if ns.UI then ns.UI:Refresh() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.State.inCombat = false
        if ns.UI then
            ns.UI:BuildReport()
            ns.UI:Refresh()
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, amount =
            CombatLogGetCurrentEventInfo()
        if destGUID == UnitGUID("player") then
            if subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE"
                or subEvent == "RANGE_DAMAGE" then
                ns.State.damageTaken = ns.State.damageTaken + (tonumber(amount) or 0)
            elseif subEvent == "UNIT_DIED" then
                ns.State.deaths = ns.State.deaths + 1
                CombatMessage("Mort détectée : vérifiez la mécanique et le timing défensif.")
            end
        end
        -- These are deliberately counters only: the addon never casts or targets.
        if sourceGUID == UnitGUID("player") and subEvent == "SPELL_INTERRUPT" then
            ns.State.interrupts = ns.State.interrupts + 1
        end
        if sourceGUID == UnitGUID("player") and subEvent == "SPELL_DISPEL" then
            ns.State.dispels = ns.State.dispels + 1
        end
    end
end)

combat:RegisterEvent("PLAYER_REGEN_DISABLED")
combat:RegisterEvent("PLAYER_REGEN_ENABLED")
combat:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
