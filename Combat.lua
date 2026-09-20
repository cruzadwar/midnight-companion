local _, ns = ...
local events = CreateFrame("Frame")
local MAX_HISTORY = 5

local function push(report)
    table.insert(ns.State.history, 1, report)
    while #ns.State.history > MAX_HISTORY do table.remove(ns.State.history) end
    ns.State.lastReport = report
end

local function begin(source, name)
    if ns.State.inCombat then return end
    ns.State.inCombat = true
    ns.State.combatStart = GetTime()
    ns.State.combatSource = source
    ns.State.encounterName = name
    ns:ResetCombat()
end

local function finish(outcome)
    if not ns.State.inCombat or not ns.State.combatStart then return end
    local duration = math.max(0, GetTime() - ns.State.combatStart)
    local report = {
        duration = duration,
        outcome = outcome or "COMBAT_END",
        encounter = ns.State.encounterName,
        summary = string.format("%s%.0fs", ns.State.encounterName and (ns.State.encounterName .. " - ") or "", duration),
        deaths = ns.State.deaths,
        interrupts = ns.State.interrupts,
        dispels = ns.State.dispels,
    }
    push(report)
    ns.State.inCombat = false
    ns.State.combatStart = nil
    ns.State.encounterName = nil
    ns.State.combatSource = nil
    ns:PrintReport(report)
end

function ns:PrintReport(report)
    report = report or self.State.lastReport
    if not report then self:Print("Aucun rapport post-combat disponible."); return end
    self:Print(string.format("Rapport : %s | %.0fs | morts %d | interruptions %d | dispels %d.",
        report.encounter or "Combat", report.duration, report.deaths, report.interrupts, report.dispels))
end

events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        begin("WORLD")
    elseif event == "PLAYER_REGEN_ENABLED" then
        finish("COMBAT_END")
    elseif event == "ENCOUNTER_START" then
        local _, encounterName = ...
        begin("ENCOUNTER", encounterName)
    elseif event == "ENCOUNTER_END" then
        local _, encounterName, _, success = ...
        ns.State.encounterName = encounterName or ns.State.encounterName
        finish(success == 1 and "SUCCESS" or "FAILURE")
    elseif event == "CHALLENGE_MODE_START" then
        ns.State.challengeActive = true
    elseif event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_RESET" then
        ns.State.challengeActive = false
    end
end)

events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("ENCOUNTER_START")
events:RegisterEvent("ENCOUNTER_END")
events:RegisterEvent("CHALLENGE_MODE_START")
events:RegisterEvent("CHALLENGE_MODE_COMPLETED")
events:RegisterEvent("CHALLENGE_MODE_RESET")
