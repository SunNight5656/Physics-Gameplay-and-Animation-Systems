$ErrorActionPreference = "Stop"

$RequiredPaths = @(
    "src\archive\pc\mod\rig.archive",
    "src\bin\x64\plugins\cyber_engine_tweaks\mods\splat_native_settings\init.lua",
    "src\bin\x64\plugins\cyber_engine_tweaks\mods\splat_native_settings\schema_index.json",
    "src\r6\scripts\new Splat"
)

$MissingPaths = @()

foreach ($Path in $RequiredPaths) {
    if (Test-Path -LiteralPath $Path) {
        Write-Host "[PASS] $Path"
    }
    else {
        Write-Host "[FAIL] $Path"
        $MissingPaths += $Path
    }
}

if ($MissingPaths.Count -gt 0) {
    Write-Error "Validation failed: $($MissingPaths.Count) required path(s) missing."
    exit 1
}

Write-Host "Validation passed."
exit 0