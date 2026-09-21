$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$required = @("MidnightCompanion.toc", "Data.lua", "Core.lua", "Combat.lua", "UI.lua")

foreach ($file in $required) {
    $path = Join-Path $root $file
    if (-not (Test-Path $path)) { throw "Fichier manquant: $file" }
    if ((Get-Content $path -Raw).Length -eq 0) { throw "Fichier vide: $file" }
}

$toc = Get-Content (Join-Path $root "MidnightCompanion.toc") -Raw
foreach ($file in $required[1..4]) {
    if ($toc -notmatch [regex]::Escape($file)) { throw "Le TOC ne référence pas $file" }
}

$core = Get-Content (Join-Path $root "Core.lua") -Raw
$data = Get-Content (Join-Path $root "Data.lua") -Raw
foreach ($api in @("UnitClass", "GetSpecializationInfo", "UnitGroupRolesAssigned")) {
    if ($core -notmatch [regex]::Escape($api)) { throw "API de détection absente: $api" }
}
foreach ($command in @("PrintDiagnostic", "PLAYER_LOGIN", "/mc status", "ShowPanel")) {
    $combined = $core + (Get-Content (Join-Path $root "UI.lua") -Raw)
    if ($combined -notmatch [regex]::Escape($command)) { throw "Diagnostic ou affichage absent: $command" }
}
$allProductText = $core + $data + (Get-Content (Join-Path $root "UI.lua") -Raw)
if ($allProductText -notmatch [regex]::Escape('generic =')) { throw "Fallback générique absent" }
foreach ($feature in @("MageDestinations", "GetMageDestinations", "TravelDestinations", "PrintTravelGuide", "/mc travel", "demande un portail à un Mage")) {
    $combined = $core + $data + (Get-Content (Join-Path $root "UI.lua") -Raw)
    if ($combined -notmatch [regex]::Escape($feature)) { throw "Aide Mage absente: $feature" }
}
$dashboard = $core + (Get-Content (Join-Path $root "UI.lua") -Raw)
foreach ($feature in @("GetDashboardData", "ONBOARDING", "PROCHAIN OBJECTIF", "ACTIONS PRIORITAIRES", "non vérifiable", 'CreateFrame("Button"', "panel:Hide()")) {
    if ($dashboard -notmatch [regex]::Escape($feature)) { throw "Tableau de bord incomplet: $feature" }
}
$locale = Get-Content (Join-Path $root "Data.lua") -Raw
foreach ($feature in @("frFR", "frBE", "frCA", "ns:T", "RoleText")) {
    if ($locale -notmatch [regex]::Escape($feature)) { throw "Localisation absente: $feature" }
}
$ui = Get-Content (Join-Path $root "UI.lua") -Raw
if ($ui -notmatch "SetSize\(400, 330\)") { throw "Panneau compact absent" }

$ui = Get-Content (Join-Path $root "UI.lua") -Raw
if ($ui -match "SecureActionButton|BackdropTemplate|StartMoving|StopMovingOrSizing|SetMovable|RegisterForDrag|EnableMouse|SetAttribute") {
    throw "API d'interface protégée détectée"
}

$combat = Get-Content (Join-Path $root "Combat.lua") -Raw
foreach ($event in @("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ENCOUNTER_START", "ENCOUNTER_END")) {
    if ($combat -notmatch [regex]::Escape($event)) { throw "Événement de cycle absent: $event" }
}
$ui = Get-Content (Join-Path $root "UI.lua") -Raw
if ($ui -match "BackdropTemplate|SecureActionButton|StartMoving|StopMovingOrSizing|SetMovable|RegisterForDrag|EnableMouse|SetAttribute") {
    throw "API d'interface protégée détectée"
}

$allLua = Get-ChildItem $root -Filter *.lua
foreach ($lua in $allLua) {
    $content = Get-Content $lua.FullName -Raw
    if ($content -match "CastSpellByName|RunMacroText|SecureActionButton") {
        throw "Automatisation interdite détectée dans $($lua.Name)"
    }
}

Write-Output "Validation addon OK: $($required.Count) fichiers requis, APIs et garde-fous vérifiés."
