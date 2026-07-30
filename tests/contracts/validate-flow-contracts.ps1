$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ManifestPath = Join-Path $PSScriptRoot "splat-flow-contracts.json"

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT TEST: GAMEPLAY FLOW CONTRACTS"
Write-Host "============================================================"
Write-Host "Tests:"
Write-Host "  - Required subsystem files exist"
Write-Host "  - Required calls and symbols still exist"
Write-Host "  - Ordered calls still appear in the required order"
Write-Host "  - Reports the subsystem, file, and exact failed pattern"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    Write-Host "[FAIL] FLOW MANIFEST | Missing file"
    Write-Host "       $ManifestPath"
    exit 1
}

try {
    $Manifest = Get-Content -LiteralPath $ManifestPath -Raw |
        ConvertFrom-Json
}
catch {
    Write-Host "[FAIL] FLOW MANIFEST | Invalid JSON"
    Write-Host "       $($_.Exception.Message)"
    exit 1
}

$Passed = 0
$Failed = 0

foreach ($Contract in $Manifest.contracts) {
    $ContractName = [string]$Contract.name
    $RelativeFile = [string]$Contract.file
    $FullPath = Join-Path $RepositoryRoot $RelativeFile

    $Failures = @()

    if (-not (Test-Path -LiteralPath $FullPath)) {
        $Failures += "Required file is missing: $RelativeFile"
    }
    else {
        $Content = Get-Content -LiteralPath $FullPath -Raw

        foreach ($Pattern in @($Contract.requiredPatterns)) {
            if ([string]::IsNullOrWhiteSpace($Pattern)) {
                continue
            }

            $Index = $Content.IndexOf(
                [string]$Pattern,
                [System.StringComparison]::OrdinalIgnoreCase
            )

            if ($Index -lt 0) {
                $Failures += "Missing required call or symbol: $Pattern"
            }
        }

        $PreviousIndex = -1
        $PreviousPattern = $null

        foreach ($Pattern in @($Contract.orderedPatterns)) {
            if ([string]::IsNullOrWhiteSpace($Pattern)) {
                continue
            }

            $CurrentIndex = $Content.IndexOf(
                [string]$Pattern,
                [System.StringComparison]::OrdinalIgnoreCase
            )

            if ($CurrentIndex -lt 0) {
                $Failures += "Ordered call is missing: $Pattern"
                continue
            }

            if ($PreviousIndex -ge 0 -and $CurrentIndex -le $PreviousIndex) {
                $Failures += "Call order changed: '$Pattern' must appear after '$PreviousPattern'"
            }

            $PreviousIndex = $CurrentIndex
            $PreviousPattern = $Pattern
        }
    }

    if ($Failures.Count -eq 0) {
        $RequiredCount = @($Contract.requiredPatterns).Count
        $OrderedCount = @($Contract.orderedPatterns).Count

        Write-Host "[PASS] $ContractName"
        Write-Host "       File: $RelativeFile"
        Write-Host "       Required patterns: $RequiredCount"
        Write-Host "       Ordered patterns:  $OrderedCount"

        $Passed++
    }
    else {
        Write-Host "[FAIL] $ContractName"
        Write-Host "       File: $RelativeFile"

        foreach ($Failure in $Failures) {
            Write-Host "       - $Failure"
        }

        $Failed++
    }

    Write-Host ""
}

Write-Host "============================================================"
Write-Host "GAMEPLAY FLOW SUMMARY"
Write-Host "============================================================"
Write-Host "Passed: $Passed"
Write-Host "Failed: $Failed"
Write-Host "Total:  $($Manifest.contracts.Count)"
Write-Host "============================================================"

if ($Failed -gt 0) {
    exit 1
}

exit 0