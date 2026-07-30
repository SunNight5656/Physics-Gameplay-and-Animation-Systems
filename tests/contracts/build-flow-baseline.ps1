$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ContractMapPath = Join-Path $PSScriptRoot "splat-flow-contracts.json"
$BaselinePath = Join-Path $PSScriptRoot "splat-flow-baseline.json"

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT: BUILD EXACT FLOW BASELINE"
Write-Host "============================================================"
Write-Host "Reads the current working SPLAT source and records:"
Write-Host "  - Exact function definitions"
Write-Host "  - REDscript method annotations"
Write-Host "  - Exact function-call sequence"
Write-Host "  - Source file assigned to each subsystem"
Write-Host ""
Write-Host "This replaces guessed function names with real source data."
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path -LiteralPath $ContractMapPath)) {
    Write-Host "[FAIL] CONTRACT MAP | File is missing"
    Write-Host "       $ContractMapPath"
    exit 1
}

try {
    $ContractMap = Get-Content -LiteralPath $ContractMapPath -Raw |
        ConvertFrom-Json
}
catch {
    Write-Host "[FAIL] CONTRACT MAP | Invalid JSON"
    Write-Host "       $($_.Exception.Message)"
    exit 1
}

function Get-CleanSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    # Remove block comments.
    $Clean = [regex]::Replace(
        $Text,
        '(?s)/\*.*?\*/',
        ''
    )

    # Remove single-line comments.
    $Clean = [regex]::Replace(
        $Clean,
        '(?m)//.*$',
        ''
    )

    # Remove string contents so words inside messages are not treated as calls.
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

    $DefinitionPattern = '(?im)^\s*(?:(?:public|private|protected|static|final|native|abstract|cb|callback)\s+)*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('

    return @(
        [regex]::Matches($Source, $DefinitionPattern) |
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

    $AnnotationPattern = '(?i)@(wrapMethod|addMethod|replaceMethod)\s*\(\s*([^)]+?)\s*\)'

    return @(
        [regex]::Matches($Source, $AnnotationPattern) |
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

    # Remove function declaration names so declarations are not mistaken
    # for function calls.
    $SourceWithoutDeclarations = [regex]::Replace(
        $Source,
        '(?im)\bfunc\s+[A-Za-z_][A-Za-z0-9_]*\s*\(',
        'func('
    )

    $CallPattern = '(?<![A-Za-z0-9_])([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\s*\('

    $IgnoredCalls = @(
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

    foreach ($Match in [regex]::Matches($SourceWithoutDeclarations, $CallPattern)) {
        $CallName = $Match.Groups[1].Value
        $LowerName = $CallName.ToLowerInvariant()

        if ($IgnoredCalls -contains $LowerName) {
            continue
        }

        $Calls.Add($CallName)
    }

    return @($Calls)
}

$BaselineContracts = @()
$Passed = 0
$Failed = 0

foreach ($Contract in @($ContractMap.contracts)) {
    $Name = [string]$Contract.name
    $RelativeFile = ([string]$Contract.file).Replace("\", "/")
    $FullPath = Join-Path $RepositoryRoot $RelativeFile

    if (-not (Test-Path -LiteralPath $FullPath)) {
        Write-Host "[FAIL] $Name"
        Write-Host "       Missing source file: $RelativeFile"
        Write-Host ""

        $Failed++
        continue
    }

    $RawSource = Get-Content -LiteralPath $FullPath -Raw
    $CleanSource = Get-CleanSource -Text $RawSource

    $Definitions = @(
        Get-FunctionDefinitions -Source $CleanSource
    )

    $Annotations = @(
        Get-MethodAnnotations -Source $CleanSource
    )

    $Calls = @(
        Get-CallSequence -Source $CleanSource
    )

    $BaselineContracts += [PSCustomObject]@{
        name        = $Name
        file        = $RelativeFile
        definitions = $Definitions
        annotations = $Annotations
        calls       = $Calls
    }

    Write-Host "[PASS] $Name"
    Write-Host "       File:        $RelativeFile"
    Write-Host "       Functions:   $($Definitions.Count)"
    Write-Host "       Annotations: $($Annotations.Count)"
    Write-Host "       Calls:       $($Calls.Count)"
    Write-Host ""

    $Passed++
}

$Commit = "unknown"

try {
    $CommitResult = git -C $RepositoryRoot rev-parse HEAD 2>$null

    if ($LASTEXITCODE -eq 0) {
        $Commit = [string]$CommitResult
    }
}
catch {
    $Commit = "unknown"
}

$Baseline = [PSCustomObject]@{
    schemaVersion = 1
    generatedAt   = (Get-Date).ToString("o")
    sourceCommit  = $Commit
    description   = "Exact SPLAT function definitions, annotations, and call order captured from the known-good source."
    contracts     = $BaselineContracts
}

$Baseline |
    ConvertTo-Json -Depth 20 |
    Set-Content -LiteralPath $BaselinePath -Encoding UTF8

Write-Host "============================================================"
Write-Host "FLOW BASELINE SUMMARY"
Write-Host "============================================================"
Write-Host "Passed:  $Passed"
Write-Host "Failed:  $Failed"
Write-Host "Baseline: $BaselinePath"
Write-Host "Commit:   $Commit"
Write-Host "============================================================"

if ($Failed -gt 0) {
    Write-Host "[FAIL] Baseline was not complete."
    exit 1
}

Write-Host "[PASS] Exact SPLAT flow baseline created."
exit 0