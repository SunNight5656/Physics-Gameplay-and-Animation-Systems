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

if ($InitText -notmatch 'bucket\[setting\.id\]\s*=\s*setting\._sectionMaster\s*==\s*true\s+and\s+false\s+or\s+false') {
    [void]$Failures.Add("New UI visibility gates do not default to false.")
}

if ($InitText -notmatch 'isShowGate\(setting,\s*gates\)\s+and\s+\(?false\)?\s+or') {
    [void]$Failures.Add("Native Settings can still reset a Show control to true.")
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

function Find-TrueVisibilityValues {
    param(
        [object]$Node,
        [string]$Path = "root"
    )

    if ($null -eq $Node) { return }

    if ($Node -is [bool]) {
        if ($Node) { [void]$Failures.Add("Packaged UI visibility is true: $Path") }
        return
    }

    if ($Node -is [string] -or $Node -is [ValueType]) { return }

    if ($Node -is [System.Collections.IEnumerable] -and $Node -isnot [PSCustomObject]) {
        $Index = 0
        foreach ($Item in $Node) {
            Find-TrueVisibilityValues -Node $Item -Path "$Path[$Index]"
            $Index++
        }
        return
    }

    foreach ($Property in $Node.PSObject.Properties) {
        Find-TrueVisibilityValues -Node $Property.Value -Path "$Path.$($Property.Name)"
    }
}

Find-TrueVisibilityValues -Node $PackagedState

if ($Failures.Count -gt 0) {
    Write-Host "[FAIL] Default menu visibility is not fully collapsed:" -ForegroundColor Red
    $Failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "[PASS] Every non-global mode section starts collapsed by default."
exit 0
