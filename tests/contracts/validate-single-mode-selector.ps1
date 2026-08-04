$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$MenuRoot = Join-Path $RepositoryRoot "src\bin\x64\plugins\cyber_engine_tweaks\mods\splat_native_settings"
$InitPath = Join-Path $MenuRoot "init.lua"
$SchemaPath = Join-Path $MenuRoot "schema_index.json"
$Failures = New-Object System.Collections.Generic.List[string]

$InitText = Get-Content -LiteralPath $InitPath -Raw
$Schema = Get-Content -LiteralPath $SchemaPath -Raw | ConvertFrom-Json

$ModeDefinitions = @($Schema.globalSettings | Where-Object { $_.id -eq $Schema.modeSettingId })
if ($ModeDefinitions.Count -ne 1) {
    [void]$Failures.Add("schema_index.json must contain exactly one global mode selector definition; found $($ModeDefinitions.Count).")
}

$SelectorRegistrations = [regex]::Matches(
    $InitText,
    'globalModeRef\s*=\s*addSetting\(GLOBAL_PATH,\s*modeSetting,\s*1,\s*"global",\s*\{\},\s*rebuildSelectedMenu,\s*false\)'
)
if ($SelectorRegistrations.Count -ne 1) {
    [void]$Failures.Add("init.lua must register exactly one persistent global mode selector; found $($SelectorRegistrations.Count).")
}

$ModeRebuildStart = $InitText.IndexOf("  local function rebuildSelectedMenu()")
$ModeRebuildEnd = $InitText.IndexOf("  globalModeRef =", $ModeRebuildStart)
if ($ModeRebuildStart -lt 0 -or $ModeRebuildEnd -le $ModeRebuildStart) {
    [void]$Failures.Add("Could not isolate rebuildSelectedMenu().")
}
else {
    $ModeRebuild = $InitText.Substring($ModeRebuildStart, $ModeRebuildEnd - $ModeRebuildStart)
    if ($ModeRebuild -match 'nativeSettings\.refresh\s*\(') {
        [void]$Failures.Add("rebuildSelectedMenu() explicitly refreshes Native Settings and can duplicate the persistent mode selector.")
    }
    if ($ModeRebuild -notmatch 'removeModeCategories\(candidate\)') {
        [void]$Failures.Add("rebuildSelectedMenu() no longer removes the previous mode categories.")
    }
    if ($ModeRebuild -notmatch 'showModeCategories\(active,') {
        [void]$Failures.Add("rebuildSelectedMenu() no longer renders the newly selected mode.")
    }
}

$ImpulseRebuildStart = $InitText.IndexOf("rebuildGlobalImpulseControls = function(section)")
$ImpulseRebuildEnd = $InitText.IndexOf("local function buildMenu()", $ImpulseRebuildStart)
if ($ImpulseRebuildStart -lt 0 -or $ImpulseRebuildEnd -le $ImpulseRebuildStart) {
    [void]$Failures.Add("Could not isolate rebuildGlobalImpulseControls().")
}
else {
    $ImpulseRebuild = $InitText.Substring($ImpulseRebuildStart, $ImpulseRebuildEnd - $ImpulseRebuildStart)
    if ($ImpulseRebuild -match 'nativeSettings\.refresh\s*\(') {
        [void]$Failures.Add("rebuildGlobalImpulseControls() explicitly refreshes Native Settings and can duplicate the persistent mode selector.")
    }
}

if ($InitText -notmatch 'writeVar\(setting,\s*math\.floor\(value\),\s*true\)\s*\r?\n\s*if rebuild then defer\(rebuild\) end') {
    [void]$Failures.Add("The mode selector no longer writes the selected mode before rebuilding dynamic categories.")
}

if ($Failures.Count -gt 0) {
    Write-Host "[FAIL] Single mode selector lifecycle is not protected:" -ForegroundColor Red
    $Failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "[PASS] One persistent mode selector owns every dynamic mode rebuild."
exit 0
