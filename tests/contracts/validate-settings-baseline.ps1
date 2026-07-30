$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$BaselinePath = Join-Path $PSScriptRoot "splat-settings-baseline.json"

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT TEST: EXACT SETTINGS BASELINE"
Write-Host "============================================================"
Write-Host "Tests:"
Write-Host "  - Every trusted JSON file still exists"
Write-Host "  - Every JSON file still parses"
Write-Host "  - Every trusted JSON property path still exists"
Write-Host "  - Every trusted Lua settings identifier still exists"
Write-Host "  - Every trusted REDscript settings field still exists"
Write-Host "  - Every trusted bridge function still exists"
Write-Host ""
Write-Host "Failures identify the exact file and removed item."
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path -LiteralPath $BaselinePath)) {
    Write-Host "[FAIL] SETTINGS BASELINE"
    Write-Host "       Missing: $BaselinePath"
    exit 1
}

try {
    $Baseline = Get-Content -LiteralPath $BaselinePath -Raw |
        ConvertFrom-Json
}
catch {
    Write-Host "[FAIL] SETTINGS BASELINE"
    Write-Host "       Invalid JSON: $($_.Exception.Message)"
    exit 1
}

function Get-JsonPropertyPaths {
    param(
        [AllowNull()]
        $Object,

        [string]$Prefix = ""
    )

    $Results = New-Object System.Collections.Generic.List[string]

    if ($null -eq $Object) {
        if ($Prefix) {
            $Results.Add($Prefix)
        }

        return @($Results)
    }

    if ($Object -is [System.Management.Automation.PSCustomObject]) {
        foreach ($Property in $Object.PSObject.Properties) {
            if ($Prefix) {
                $Path = "$Prefix.$($Property.Name)"
            }
            else {
                $Path = $Property.Name
            }

            foreach (
                $ChildPath in Get-JsonPropertyPaths `
                    -Object $Property.Value `
                    -Prefix $Path
            ) {
                $Results.Add($ChildPath)
            }
        }

        return @($Results)
    }

    if (
        $Object -is [System.Collections.IEnumerable] -and
        $Object -isnot [string]
    ) {
        $Index = 0

        foreach ($Item in $Object) {
            $Path = "$Prefix[$Index]"

            foreach (
                $ChildPath in Get-JsonPropertyPaths `
                    -Object $Item `
                    -Prefix $Path
            ) {
                $Results.Add($ChildPath)
            }

            $Index++
        }

        if ($Index -eq 0 -and $Prefix) {
            $Results.Add($Prefix)
        }

        return @($Results)
    }

    if ($Prefix) {
        $Results.Add($Prefix)
    }

    return @($Results)
}

function Get-LuaStrings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $Pattern = @'
(?x)
(?:
    "((?:\\.|[^"\\])*)"
  |
    '((?:\\.|[^'\\])*)'
)
'@

    return @(
        [regex]::Matches($Source, $Pattern) |
            ForEach-Object {
                if ($_.Groups[1].Success) {
                    $_.Groups[1].Value
                }
                else {
                    $_.Groups[2].Value
                }
            } |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            } |
            Sort-Object -Unique
    )
}

function Get-RedscriptFields {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $Pattern = '(?im)^\s*(?:public\s+|private\s+|protected\s+)?let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:'

    return @(
        [regex]::Matches($Source, $Pattern) |
            ForEach-Object {
                $_.Groups[1].Value
            } |
            Sort-Object -Unique
    )
}

function Get-RedscriptFunctions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $Pattern = '(?im)^\s*(?:(?:public|private|protected|static|final|native|abstract|cb|callback)\s+)*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('

    return @(
        [regex]::Matches($Source, $Pattern) |
            ForEach-Object {
                $_.Groups[1].Value
            } |
            Sort-Object -Unique
    )
}

function Get-MissingValues {
    param(
        [array]$Expected,
        [array]$Current
    )

    return @(
        $Expected |
            Where-Object {
                $_ -notin $Current
            }
    )
}

$Passed = 0
$Failed = 0

foreach ($JsonRecord in @($Baseline.jsonFiles)) {
    $RelativeFile = ([string]$JsonRecord.file).Replace("\", "/")
    $FullPath = Join-Path $RepositoryRoot $RelativeFile
    $Failures = @()

    if (-not (Test-Path -LiteralPath $FullPath)) {
        $Failures += "JSON file removed: $RelativeFile"
    }
    else {
        try {
            $CurrentObject = Get-Content -LiteralPath $FullPath -Raw |
                ConvertFrom-Json

            $CurrentPaths = @(
                Get-JsonPropertyPaths -Object $CurrentObject |
                    Sort-Object -Unique
            )

            $MissingPaths = @(
                Get-MissingValues `
                    -Expected @($JsonRecord.propertyPaths) `
                    -Current $CurrentPaths
            )

            foreach ($Path in $MissingPaths) {
                $Failures += "JSON property removed: $Path"
            }
        }
        catch {
            $Failures += "JSON does not parse: $($_.Exception.Message)"
        }
    }

    if ($Failures.Count -eq 0) {
        Write-Host "[PASS] JSON SETTINGS | $RelativeFile"
        Write-Host "       Properties preserved: $(@($JsonRecord.propertyPaths).Count)"
        $Passed++
    }
    else {
        Write-Host "[FAIL] JSON SETTINGS | $RelativeFile"

        foreach ($Failure in $Failures) {
            Write-Host "       - $Failure"
        }

        $Failed++
    }

    Write-Host ""
}

$LuaRelativeFile = ([string]$Baseline.lua.file).Replace("\", "/")
$LuaFullPath = Join-Path $RepositoryRoot $LuaRelativeFile
$LuaFailures = @()

if (-not (Test-Path -LiteralPath $LuaFullPath)) {
    $LuaFailures += "Native Settings Lua file was removed"
}
else {
    $LuaSource = Get-Content -LiteralPath $LuaFullPath -Raw
    $CurrentLuaStrings = @(Get-LuaStrings -Source $LuaSource)

    $MissingLuaStrings = @(
        Get-MissingValues `
            -Expected @($Baseline.lua.strings) `
            -Current $CurrentLuaStrings
    )

    foreach ($Value in $MissingLuaStrings) {
        $LuaFailures += "Lua string or identifier removed: $Value"
    }
}

if ($LuaFailures.Count -eq 0) {
    Write-Host "[PASS] NATIVE SETTINGS LUA"
    Write-Host "       File: $LuaRelativeFile"
    Write-Host "       Strings preserved: $(@($Baseline.lua.strings).Count)"
    $Passed++
}
else {
    Write-Host "[FAIL] NATIVE SETTINGS LUA"
    Write-Host "       File: $LuaRelativeFile"

    foreach ($Failure in $LuaFailures) {
        Write-Host "       - $Failure"
    }

    $Failed++
}

Write-Host ""

foreach ($RedscriptRecord in @($Baseline.redscript)) {
    $RelativeFile = ([string]$RedscriptRecord.file).Replace("\", "/")
    $FullPath = Join-Path $RepositoryRoot $RelativeFile
    $Failures = @()

    if (-not (Test-Path -LiteralPath $FullPath)) {
        $Failures += "REDscript settings file removed: $RelativeFile"
    }
    else {
        $Source = Get-Content -LiteralPath $FullPath -Raw

        $CurrentFields = @(
            Get-RedscriptFields -Source $Source
        )

        $CurrentFunctions = @(
            Get-RedscriptFunctions -Source $Source
        )

        $MissingFields = @(
            Get-MissingValues `
                -Expected @($RedscriptRecord.fields) `
                -Current $CurrentFields
        )

        $MissingFunctions = @(
            Get-MissingValues `
                -Expected @($RedscriptRecord.functions) `
                -Current $CurrentFunctions
        )

        foreach ($Field in $MissingFields) {
            $Failures += "REDscript settings field removed: $Field"
        }

        foreach ($Function in $MissingFunctions) {
            $Failures += "REDscript bridge function removed: $Function"
        }
    }

    if ($Failures.Count -eq 0) {
        Write-Host "[PASS] REDSCRIPT SETTINGS | $RelativeFile"
        Write-Host "       Fields preserved:    $(@($RedscriptRecord.fields).Count)"
        Write-Host "       Functions preserved: $(@($RedscriptRecord.functions).Count)"
        $Passed++
    }
    else {
        Write-Host "[FAIL] REDSCRIPT SETTINGS | $RelativeFile"

        foreach ($Failure in $Failures) {
            Write-Host "       - $Failure"
        }

        $Failed++
    }

    Write-Host ""
}

Write-Host "============================================================"
Write-Host "EXACT SETTINGS BASELINE SUMMARY"
Write-Host "============================================================"
Write-Host "Trusted commit: $($Baseline.sourceCommit)"
Write-Host "Passed:         $Passed"
Write-Host "Failed:         $Failed"
Write-Host "============================================================"

if ($Failed -gt 0) {
    exit 1
}

exit 0