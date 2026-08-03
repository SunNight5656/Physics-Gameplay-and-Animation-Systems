$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Failures = New-Object System.Collections.Generic.List[string]

$SettingsPath = Join-Path $RepositoryRoot "src\r6\scripts\new Splat\SPLATSettingsData.reds"
$SettingsText = Get-Content -LiteralPath $SettingsPath -Raw

$ModeFields = @(
    "customTripEmotion_showPushReactionPopup",
    "realismPlusTripEmotion_showPushReactionPopup",
    "dirtyTripEmotion_showPushReactionPopup",
    "arnoldTripEmotion_showPushReactionPopup"
)

foreach ($Field in $ModeFields) {
    $Pattern = "(?m)^\s*public let $([regex]::Escape($Field)): Bool = false;\s*$"

    if ($SettingsText -notmatch $Pattern) {
        [void]$Failures.Add("REDscript default is not false: $Field")
    }
}

$TripRuntimePath = Join-Path $RepositoryRoot "src\r6\scripts\new Splat\Features\00_AAA_Trip_Emotion.reds"
$TripRuntimeText = Get-Content -LiteralPath $TripRuntimePath -Raw

if ($TripRuntimeText -notmatch "(?m)^\s*public let showPushReactionPopup: Bool = false;\s*$") {
    [void]$Failures.Add("Trip runtime fallback default is not false.")
}

$SectionRoot = Join-Path $RepositoryRoot "src\bin\x64\plugins\cyber_engine_tweaks\mods\splat_native_settings\sections"

$Sections = @(
    @{
        File  = "realismCustom__trip.json"
        Field = "customTripEmotion_showPushReactionPopup"
    },
    @{
        File  = "realismPlus__trip.json"
        Field = "realismPlusTripEmotion_showPushReactionPopup"
    },
    @{
        File  = "dirtyHarry__trip.json"
        Field = "dirtyTripEmotion_showPushReactionPopup"
    },
    @{
        File  = "arnoldArcade__trip.json"
        Field = "arnoldTripEmotion_showPushReactionPopup"
    }
)

foreach ($Section in $Sections) {
    $SectionPath = Join-Path $SectionRoot $Section.File
    $SectionText = Get-Content -LiteralPath $SectionPath -Raw
    $EscapedField = [regex]::Escape($Section.Field)

    $Pattern = "(?s)""name""\s*:\s*""$EscapedField""(?:(?!\}).)*?""default""\s*:\s*false"

    if ($SectionText -notmatch $Pattern) {
        [void]$Failures.Add("Native Settings default is not false: $($Section.File)")
    }
}

if ($Failures.Count -gt 0) {
    Write-Host "[FAIL] Trip debug popup defaults are incorrect:" -ForegroundColor Red
    $Failures | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Red
    }

    exit 1
}

Write-Host "[PASS] Trip debug popup defaults are Off in every mode."
exit 0