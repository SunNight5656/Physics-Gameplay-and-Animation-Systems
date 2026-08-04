$ErrorActionPreference = "Continue"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT COMPLETE REGRESSION SUITE"
Write-Host "============================================================"
Write-Host "Repository: $RepositoryRoot"
Write-Host ""

$Tests = @(
    @{
        Name   = "PACKAGE STRUCTURE"
        Script = "scripts\validate-package.ps1"
    },
    @{
        Name   = "REQUIRED FILE INVENTORY"
        Script = "tests\contracts\validate-required-files.ps1"
    },
    @{
        Name   = "EXACT GAMEPLAY FLOW"
        Script = "tests\contracts\validate-exact-flow-baseline.ps1"
    },
    @{
        Name   = "EXACT SETTINGS STRUCTURE"
        Script = "tests\contracts\validate-settings-baseline.ps1"
    },
    @{
        Name   = "DEFAULT MENU VISIBILITY"
        Script = "tests\contracts\validate-default-menu-visibility.ps1"
    },
    @{
        Name   = "OBSOLETE MENU CONTROLS"
        Script = "tests\contracts\validate-obsolete-controls.ps1"
    },
    @{
        Name   = "SINGLE MODE SELECTOR"
        Script = "tests\contracts\validate-single-mode-selector.ps1"
    },
    @{
        Name   = "TRIP DEBUG POPUP DEFAULTS"
        Script = "tests\contracts\validate-trip-debug-defaults.ps1"
    }
)
$Passed = 0
$Failed = 0
$Results = @()

foreach ($Test in $Tests) {
    $TestPath = Join-Path $RepositoryRoot $Test.Script

    Write-Host "------------------------------------------------------------"
    Write-Host "TESTING: $($Test.Name)"
    Write-Host "SCRIPT:  $($Test.Script)"
    Write-Host "------------------------------------------------------------"

    if (-not (Test-Path -LiteralPath $TestPath)) {
        Write-Host "[FAIL] $($Test.Name) | Test script is missing"
        Write-Host "       Missing: $TestPath"

        $Results += [PSCustomObject]@{
            Test   = $Test.Name
            Result = "FAIL"
            Detail = "Test script missing"
        }

        $Failed++
        Write-Host ""
        continue
    }

    $Output = & powershell `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $TestPath 2>&1

    $ExitCode = $LASTEXITCODE

    if ($ExitCode -eq 0) {
        Write-Host "[PASS] $($Test.Name)"

        $Results += [PSCustomObject]@{
            Test   = $Test.Name
            Result = "PASS"
            Detail = "All checks passed"
        }

        $Passed++
    }
    else {
        Write-Host "[FAIL] $($Test.Name) | Exit code $ExitCode"

        foreach ($Line in $Output) {
            Write-Host "       $Line"
        }

        $Results += [PSCustomObject]@{
            Test   = $Test.Name
            Result = "FAIL"
            Detail = "See failure output above"
        }

        $Failed++
    }

    Write-Host ""
}

Write-Host "============================================================"
Write-Host "SPLAT REGRESSION SUMMARY"
Write-Host "============================================================"

foreach ($Result in $Results) {
    if ($Result.Result -eq "PASS") {
        Write-Host "[PASS] $($Result.Test)"
    }
    else {
        Write-Host "[FAIL] $($Result.Test) | $($Result.Detail)"
    }
}

Write-Host ""
Write-Host "Passed: $Passed"
Write-Host "Failed: $Failed"
Write-Host "Total:  $($Tests.Count)"
Write-Host "============================================================"

if ($Failed -gt 0) {
    exit 1
}

exit 0
