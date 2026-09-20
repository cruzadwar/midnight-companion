[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Apply,
    [string[]]$WorldOfWarcraftPath
)

$ErrorActionPreference = "Stop"

$running = @(Get-Process -Name "Wow", "WowClassic" -ErrorAction SilentlyContinue)
if ($running.Count -gt 0) {
    $names = ($running | Select-Object -ExpandProperty ProcessName -Unique) -join ", "
    Write-Error "Le nettoyage est bloque car WoW est encore ouvert : $names. Fermez le jeu, puis relancez le nettoyeur."
}

function Get-CandidateRoots {
    param([string[]]$ExplicitPath)

    $roots = New-Object System.Collections.Generic.List[string]
    if ($ExplicitPath -and $ExplicitPath.Count -gt 0) {
        foreach ($path in $ExplicitPath) {
            if ($path -and (Test-Path -LiteralPath $path)) {
                $roots.Add((Resolve-Path -LiteralPath $path).Path)
            }
        }
        return $roots
    }

    $defaults = @(
        "${env:ProgramFiles(x86)}\World of Warcraft",
        "$env:ProgramFiles\World of Warcraft",
        "$env:PUBLIC\Games\World of Warcraft",
        "$env:SystemDrive\Games\World of Warcraft"
    )
    foreach ($path in $defaults) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            $resolved = (Resolve-Path -LiteralPath $path).Path
            if (-not $roots.Contains($resolved)) { $roots.Add($resolved) }
        }
    }
    return $roots
}

function Get-AddonTargets {
    param([string[]]$Roots)

    $targets = New-Object System.Collections.Generic.List[string]
    foreach ($root in $Roots) {
        foreach ($flavor in @("_retail_", "_classic_", "_classic_era_", "_ptr_", "_beta_")) {
            $addons = Join-Path $root "$flavor\Interface\AddOns"
            if (-not (Test-Path -LiteralPath $addons)) { continue }

            $exact = Join-Path $addons "MidnightCompanion"
            if (Test-Path -LiteralPath $exact) { $targets.Add((Resolve-Path -LiteralPath $exact).Path) }

            Get-ChildItem -LiteralPath $addons -Directory -Filter "MidnightCompanion-*" -ErrorAction SilentlyContinue |
                ForEach-Object { $targets.Add($_.FullName) }
        }
    }
    return $targets | Sort-Object -Unique
}

$roots = @(Get-CandidateRoots -ExplicitPath $WorldOfWarcraftPath)
if ($roots.Count -eq 0) {
    Write-Error "Aucune installation WoW détectée. Relancez avec -WorldOfWarcraftPath 'C:\...\World of Warcraft'."
}

$targets = @(Get-AddonTargets -Roots $roots)
Write-Output "Installations inspectées :"
$roots | ForEach-Object { Write-Output "  $_" }

if ($targets.Count -eq 0) {
    Write-Output "Aucune ancienne copie MidnightCompanion trouvée."
    exit 0
}

Write-Output ""
Write-Output "Copies trouvées :"
$targets | ForEach-Object { Write-Output "  $_" }

if (-not $Apply) {
    Write-Output ""
    Write-Output "Mode aperçu : rien n'a été supprimé."
    Write-Output "Pour supprimer uniquement ces dossiers, relancez avec -Apply."
    exit 0
}

foreach ($target in $targets) {
    if ($PSCmdlet.ShouldProcess($target, "Supprimer cette copie MidnightCompanion")) {
        Remove-Item -LiteralPath $target -Recurse -Force
        Write-Output "Supprimé : $target"
    }
}
