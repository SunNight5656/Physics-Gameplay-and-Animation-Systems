$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$MenuRoot = Join-Path $RepositoryRoot "src\bin\x64\plugins\cyber_engine_tweaks\mods\splat_native_settings"
$Failures = New-Object System.Collections.Generic.List[string]

$InitPath = Join-Path $MenuRoot "init.lua"
$InitText = Get-Content -LiteralPath $InitPath -Raw

$ClosedModeDefault = 'out\.modes\[mode\.key\]\s*=\s*\{showAll\s*=\s*false,\s*topics\s*=\s*\{\}\}'

if ($InitText -notmatch $ClosedModeDefault) {
    [void]$Failures.Add("defaultUI() does not initialize every mode with showAll = false.")
}

if ($InitText -match 'showAll\s*=\s*\(i\s*==\s*1') {
    [void]$Failures.Add("defaultUI() still automatically opens the first mode.")
}

$PackagedStatePath = Join-Path $MenuRoot "user_ui.json"
$PackagedState = Get-Content -LiteralPath $PackagedStatePath -Raw | ConvertFrom-Json

foreach ($ModeProperty in $PackagedState.modes.PSObject.Properties) {
    $ModeName = $ModeProperty.Name
    $ModeState = $ModeProperty.Value

    if ($ModeState.showAll -ne $false) {
        [void]$Failures.Add("Packaged UI state opens mode by default: $ModeName")
    }

    foreach ($TopicProperty in $ModeState.topics.PSObject.Properties) {
        if ($TopicProperty.Value -ne $false) {
            [void]$Failures.Add("Packaged UI state opens topic by default: $ModeName/$($TopicProperty.Name)")
        }
    }
}

if ($Failures.Count -gt 0) {
    Write-Host "[FAIL] Default menu visibility is not fully collapsed:" -ForegroundColor Red
    $Failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "[PASS] Every non-global mode section starts collapsed by default."
exit 0
