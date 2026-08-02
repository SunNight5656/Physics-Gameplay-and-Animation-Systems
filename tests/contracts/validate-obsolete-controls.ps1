$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$SourceRoot = Join-Path $RepositoryRoot "src"

$ForbiddenControls = @(
    "GENERAL_PATH",
    "generalImpulses",
    "General Impulses",
    "rebuildGeneralImpulses",
    "removeGeneralFallCategories"
)

$SearchExtensions = @(".reds", ".lua", ".json")
$SourceFiles = Get-ChildItem -LiteralPath $SourceRoot -File -Recurse |
    Where-Object { $_.Extension -in $SearchExtensions }

$Failures = New-Object System.Collections.Generic.List[string]

foreach ($Control in $ForbiddenControls) {
    $Pattern = "(?<![A-Za-z0-9_])$([regex]::Escape($Control))(?![A-Za-z0-9_])"
    $Matches = $SourceFiles | Select-String -Pattern $Pattern

    foreach ($Match in $Matches) {
        $RelativePath = $Match.Path.Substring($RepositoryRoot.Length).TrimStart("\")
        [void]$Failures.Add("${RelativePath}:$($Match.LineNumber): $($Match.Line.Trim())")
    }
}

if ($Failures.Count -gt 0) {
    Write-Host "[FAIL] Obsolete menu controls remain in runtime source:" -ForegroundColor Red
    $Failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "[PASS] Obsolete menu controls are absent from runtime source."
