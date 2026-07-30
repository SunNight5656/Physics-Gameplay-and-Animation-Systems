$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$BaselinePath = Join-Path $PSScriptRoot "splat-flow-baseline.json"

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT TEST: EXACT FLOW BASELINE"
Write-Host "============================================================"
Write-Host "Tests each subsystem for:"
Write-Host "  - Required source file still exists"
Write-Host "  - Existing function definitions were not removed"
Write-Host "  - Existing method annotations were not removed"
Write-Host "  - Existing function calls were not removed"
Write-Host "  - Existing call sequence remains in the same order"
Write-Host ""
Write-Host "A failure identifies the subsystem, file, and removed item."
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path -LiteralPath $BaselinePath)) {
    Write-Host "[FAIL] FLOW BASELINE"
    Write-Host "       Baseline file is missing: $BaselinePath"
    exit 1
}

try {
    $Baseline = Get-Content -LiteralPath $BaselinePath -Raw |
        ConvertFrom-Json
}
catch {
    Write-Host "[FAIL] FLOW BASELINE"
    Write-Host "       Baseline JSON is invalid."
    Write-Host "       $($_.Exception.Message)"
    exit 1
}

function Get-CleanSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    $Clean = [regex]::Replace(
        $Text,
        '(?s)/\*.*?\*/',
        ''
    )

    $Clean = [regex]::Replace(
        $Clean,
        '(?m)//.*$',
        ''
    )

    $Clean = [regex]::Replace(
        $Clean,
        '"(?:\\.|[^"\\])*"',
        '""'
    )

    return $Clean
}

function Get-FunctionDefinitions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $Pattern = '(?im)^\s*(?:(?:public|private|protected|static|final|native|abstract|cb|callback)\s+)*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('

    return @(
        [regex]::Matches($Source, $Pattern) |
            ForEach-Object {
                $_.Groups[1].Value
            }
    )
}

function Get-MethodAnnotations {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $Pattern = '(?i)@(wrapMethod|addMethod|replaceMethod)\s*\(\s*([^)]+?)\s*\)'

    return @(
        [regex]::Matches($Source, $Pattern) |
            ForEach-Object {
                $_.Value.Trim()
            }
    )
}

function Get-CallSequence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $WithoutDeclarations = [regex]::Replace(
        $Source,
        '(?im)\bfunc\s+[A-Za-z_][A-Za-z0-9_]*\s*\(',
        'func('
    )

    $Pattern = '(?<![A-Za-z0-9_])([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\s*\('

    $Ignored = @(
        "if",
        "else",
        "while",
        "for",
        "foreach",
        "switch",
        "return",
        "func",
        "class",
        "struct",
        "enum",
        "case",
        "wrapmethod",
        "addmethod",
        "replacemethod"
    )

    $Calls = New-Object System.Collections.Generic.List[string]

    foreach ($Match in [regex]::Matches($WithoutDeclarations, $Pattern)) {
        $Name = $Match.Groups[1].Value

        if ($Ignored -contains $Name.ToLowerInvariant()) {
            continue
        }

        $Calls.Add($Name)
    }

    return @($Calls)
}

function Get-MissingItems {
    param(
        [array]$Expected,
        [array]$Current
    )

    $ExpectedCounts = @{}
    $CurrentCounts = @{}

    foreach ($Item in @($Expected)) {
        $Key = ([string]$Item).ToLowerInvariant()

        if (-not $ExpectedCounts.ContainsKey($Key)) {
            $ExpectedCounts[$Key] = @{
                Name  = [string]$Item
                Count = 0
            }
        }

        $ExpectedCounts[$Key].Count++
    }

    foreach ($Item in @($Current)) {
        $Key = ([string]$Item).ToLowerInvariant()

        if (-not $CurrentCounts.ContainsKey($Key)) {
            $CurrentCounts[$Key] = 0
        }

        $CurrentCounts[$Key]++
    }

    $Missing = @()

    foreach ($Key in $ExpectedCounts.Keys) {
        $ExpectedCount = $ExpectedCounts[$Key].Count

        if ($CurrentCounts.ContainsKey($Key)) {
            $CurrentCount = $CurrentCounts[$Key]
        }
        else {
            $CurrentCount = 0
        }

        if ($CurrentCount -lt $ExpectedCount) {
            $Missing += [PSCustomObject]@{
                Name     = $ExpectedCounts[$Key].Name
                Expected = $ExpectedCount
                Current  = $CurrentCount
            }
        }
    }

    return @($Missing)
}

function Test-OrderedSubsequence {
    param(
        [array]$Expected,
        [array]$Current
    )

    if (@($Expected).Count -eq 0) {
        return $true
    }

    $ExpectedIndex = 0

    foreach ($CurrentItem in @($Current)) {
        $ExpectedItem = [string]$Expected[$ExpectedIndex]

        if (
            ([string]$CurrentItem).Equals(
                $ExpectedItem,
                [System.StringComparison]::OrdinalIgnoreCase
            )
        ) {
            $ExpectedIndex++

            if ($ExpectedIndex -ge @($Expected).Count) {
                return $true
            }
        }
    }

    return $false
}

$Passed = 0
$Failed = 0

foreach ($Contract in @($Baseline.contracts)) {
    $Name = [string]$Contract.name
    $RelativeFile = ([string]$Contract.file).Replace("\", "/")
    $FullPath = Join-Path $RepositoryRoot $RelativeFile
    $Failures = @()

    if (-not (Test-Path -LiteralPath $FullPath)) {
        $Failures += "Required source file was removed: $RelativeFile"
    }
    else {
        $RawSource = Get-Content -LiteralPath $FullPath -Raw
        $CleanSource = Get-CleanSource -Text $RawSource

        $CurrentDefinitions = @(
            Get-FunctionDefinitions -Source $CleanSource
        )

        $CurrentAnnotations = @(
            Get-MethodAnnotations -Source $CleanSource
        )

        $CurrentCalls = @(
            Get-CallSequence -Source $CleanSource
        )

        $MissingDefinitions = @(
            Get-MissingItems `
                -Expected @($Contract.definitions) `
                -Current $CurrentDefinitions
        )

        foreach ($Item in $MissingDefinitions) {
            $Failures += "Function removed: $($Item.Name) [$($Item.Current)/$($Item.Expected) occurrences remain]"
        }

        $MissingAnnotations = @(
            Get-MissingItems `
                -Expected @($Contract.annotations) `
                -Current $CurrentAnnotations
        )

        foreach ($Item in $MissingAnnotations) {
            $Failures += "Method annotation removed: $($Item.Name) [$($Item.Current)/$($Item.Expected) occurrences remain]"
        }

        $MissingCalls = @(
            Get-MissingItems `
                -Expected @($Contract.calls) `
                -Current $CurrentCalls
        )

        foreach ($Item in $MissingCalls) {
            $Failures += "Function call removed: $($Item.Name) [$($Item.Current)/$($Item.Expected) occurrences remain]"
        }

        if (
            $MissingCalls.Count -eq 0 -and
            -not (Test-OrderedSubsequence `
                -Expected @($Contract.calls) `
                -Current $CurrentCalls)
        ) {
            $Failures += "Function-call order changed from the trusted baseline"
        }
    }

    if ($Failures.Count -eq 0) {
        Write-Host "[PASS] $Name"
        Write-Host "       File: $RelativeFile"
        Write-Host "       Functions preserved:   $(@($Contract.definitions).Count)"
        Write-Host "       Annotations preserved: $(@($Contract.annotations).Count)"
        Write-Host "       Calls preserved:       $(@($Contract.calls).Count)"
        $Passed++
    }
    else {
        Write-Host "[FAIL] $Name"
        Write-Host "       File: $RelativeFile"

        foreach ($Failure in $Failures) {
            Write-Host "       - $Failure"
        }

        $Failed++
    }

    Write-Host ""
}

Write-Host "============================================================"
Write-Host "EXACT FLOW BASELINE SUMMARY"
Write-Host "============================================================"
Write-Host "Trusted commit: $($Baseline.sourceCommit)"
Write-Host "Passed:         $Passed"
Write-Host "Failed:         $Failed"
Write-Host "Total:          $(@($Baseline.contracts).Count)"
Write-Host "============================================================"

if ($Failed -gt 0) {
    exit 1
}

exit 0