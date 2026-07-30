$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT TEST: REQUIRED FILE INVENTORY"
Write-Host "============================================================"
Write-Host "Tests:"
Write-Host "  - Every file recorded in required-files.txt still exists"
Write-Host "  - Reports the exact path of every missing file"
Write-Host "  - Reports new files not yet recorded in the baseline"
Write-Host ""
Write-Host "Does not test:"
Write-Host "  - File contents"
Write-Host "  - Function calls"
Write-Host "  - Settings wiring"
Write-Host "  - Runtime behavior"
Write-Host "============================================================"
Write-Host ""

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$SourceRoot = (Resolve-Path (Join-Path $RepositoryRoot "src")).Path
$BaselineFile = Join-Path $RepositoryRoot "tests\baseline\required-files.txt"

Write-Host "Repository: $RepositoryRoot"
Write-Host "Source:     $SourceRoot"
Write-Host "Baseline:   $BaselineFile"
Write-Host ""

if (-not (Test-Path -LiteralPath $BaselineFile)) {
    Write-Host "[FAIL] Required-file baseline does not exist."
    Write-Host "[MISSING BASELINE] $BaselineFile"
    exit 1
}

$RequiredFiles = @(
    Get-Content -LiteralPath $BaselineFile |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_.Trim().Replace("\", "/") }
)

$CurrentFiles = @(
    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File |
        ForEach-Object {
            $_.FullName.Substring($SourceRoot.Length + 1).Replace("\", "/")
        }
)

$MissingFiles = @(
    $RequiredFiles | Where-Object { $_ -notin $CurrentFiles }
)

$NewFiles = @(
    $CurrentFiles | Where-Object { $_ -notin $RequiredFiles }
)

Write-Host "Required files tested: $($RequiredFiles.Count)"
Write-Host "Current files found:  $($CurrentFiles.Count)"
Write-Host ""

if ($NewFiles.Count -gt 0) {
    Write-Host "New files not recorded in the baseline:"
    foreach ($File in $NewFiles) {
        Write-Host "[NEW] $File"
    }
    Write-Host ""
}

if ($MissingFiles.Count -gt 0) {
    Write-Host "FILES REMOVED OR MISSING:"
    foreach ($File in $MissingFiles) {
        Write-Host "[MISSING] $File"
    }

    Write-Host ""
    Write-Host "[FAIL] Required-file inventory test failed."
    Write-Host "Missing files: $($MissingFiles.Count)"
    exit 1
}

Write-Host "[PASS] Required-file inventory test passed."
Write-Host "All $($RequiredFiles.Count) required SPLAT files still exist."
exit 0