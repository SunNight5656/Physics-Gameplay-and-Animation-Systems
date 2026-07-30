$ErrorActionPreference = "Stop"

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

$SettingsRoot = Join-Path $RepositoryRoot `
    "src\bin\x64\plugins\cyber_engine_tweaks\mods\splat_native_settings"

$LuaPath = Join-Path $SettingsRoot "init.lua"

$RedscriptFiles = @(
    "src\r6\scripts\new Splat\00_SPLATDirectSettingsSystem.reds",
    "src\r6\scripts\new Splat\SPLATSettingsData.reds",
    "src\r6\scripts\new Splat\Types.reds"
)

$BaselinePath = Join-Path $PSScriptRoot "splat-settings-baseline.json"

Write-Host ""
Write-Host "============================================================"
Write-Host "SPLAT: BUILD SETTINGS BASELINE"
Write-Host "============================================================"
Write-Host "Records the working settings system:"
Write-Host "  - Every JSON settings file"
Write-Host "  - Every JSON property path"
Write-Host "  - Every Lua string used by Native Settings"
Write-Host "  - Every REDscript settings field"
Write-Host "  - Every REDscript bridge function"
Write-Host "============================================================"
Write-Host ""

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

            $ChildPaths = Get-JsonPropertyPaths `
                -Object $Property.Value `
                -Prefix $Path

            foreach ($ChildPath in $ChildPaths) {
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

            $ChildPaths = Get-JsonPropertyPaths `
                -Object $Item `
                -Prefix $Path

            foreach ($ChildPath in $ChildPaths) {
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

    $Strings = New-Object System.Collections.Generic.List[string]

    $Pattern = @'
(?x)
(?:
    "((?:\\.|[^"\\])*)"
  |
    '((?:\\.|[^'\\])*)'
)
'@

    foreach ($Match in [regex]::Matches($Source, $Pattern)) {
        if ($Match.Groups[1].Success) {
            $Value = $Match.Groups[1].Value
        }
        else {
            $Value = $Match.Groups[2].Value
        }

        if (-not [string]::IsNullOrWhiteSpace($Value)) {
            $Strings.Add($Value)
        }
    }

    return @(
        $Strings |
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

if (-not (Test-Path -LiteralPath $SettingsRoot)) {
    Write-Host "[FAIL] SETTINGS ROOT"
    Write-Host "       Missing: $SettingsRoot"
    exit 1
}

if (-not (Test-Path -LiteralPath $LuaPath)) {
    Write-Host "[FAIL] NATIVE SETTINGS LUA"
    Write-Host "       Missing: $LuaPath"
    exit 1
}

$JsonRecords = @()
$JsonFailures = 0

$JsonFiles = @(
    Get-ChildItem -LiteralPath $SettingsRoot -Recurse -Filter "*.json" -File |
        Sort-Object FullName
)

foreach ($JsonFile in $JsonFiles) {
    $RelativePath = $JsonFile.FullName.Substring($RepositoryRoot.Length + 1).Replace("\", "/")

    try {
        $JsonObject = Get-Content -LiteralPath $JsonFile.FullName -Raw |
            ConvertFrom-Json

        $PropertyPaths = @(
            Get-JsonPropertyPaths -Object $JsonObject |
                Sort-Object -Unique
        )

        $JsonRecords += [PSCustomObject]@{
            file          = $RelativePath
            propertyPaths = $PropertyPaths
        }

        Write-Host "[PASS] JSON"
        Write-Host "       File:       $RelativePath"
        Write-Host "       Properties: $($PropertyPaths.Count)"
    }
    catch {
        Write-Host "[FAIL] JSON"
        Write-Host "       File:  $RelativePath"
        Write-Host "       Error: $($_.Exception.Message)"

        $JsonFailures++
    }

    Write-Host ""
}

$LuaSource = Get-Content -LiteralPath $LuaPath -Raw
$LuaStrings = @(Get-LuaStrings -Source $LuaSource)

Write-Host "[PASS] NATIVE SETTINGS LUA"
Write-Host "       File:    $($LuaPath.Substring($RepositoryRoot.Length + 1))"
Write-Host "       Strings: $($LuaStrings.Count)"
Write-Host ""

$RedscriptRecords = @()
$MissingRedscriptFiles = 0

foreach ($RelativeFile in $RedscriptFiles) {
    $FullPath = Join-Path $RepositoryRoot $RelativeFile

    if (-not (Test-Path -LiteralPath $FullPath)) {
        Write-Host "[FAIL] REDSCRIPT SETTINGS FILE"
        Write-Host "       Missing: $RelativeFile"
        Write-Host ""

        $MissingRedscriptFiles++
        continue
    }

    $Source = Get-Content -LiteralPath $FullPath -Raw

    $Fields = @(
        Get-RedscriptFields -Source $Source
    )

    $Functions = @(
        Get-RedscriptFunctions -Source $Source
    )

    $RedscriptRecords += [PSCustomObject]@{
        file      = $RelativeFile.Replace("\", "/")
        fields    = $Fields
        functions = $Functions
    }

    Write-Host "[PASS] REDSCRIPT SETTINGS"
    Write-Host "       File:      $RelativeFile"
    Write-Host "       Fields:    $($Fields.Count)"
    Write-Host "       Functions: $($Functions.Count)"
    Write-Host ""
}

$Commit = "unknown"

try {
    $CommitOutput = git -C $RepositoryRoot rev-parse HEAD 2>$null

    if ($LASTEXITCODE -eq 0) {
        $Commit = [string]$CommitOutput
    }
}
catch {
    $Commit = "unknown"
}

$Baseline = [PSCustomObject]@{
    schemaVersion = 1
    generatedAt   = (Get-Date).ToString("o")
    sourceCommit  = $Commit
    description   = "Trusted SPLAT JSON, Lua, and REDscript settings inventory."
    jsonFiles     = $JsonRecords
    lua           = [PSCustomObject]@{
        file    = $LuaPath.Substring($RepositoryRoot.Length + 1).Replace("\", "/")
        strings = $LuaStrings
    }
    redscript     = $RedscriptRecords
}

$Baseline |
    ConvertTo-Json -Depth 30 |
    Set-Content -LiteralPath $BaselinePath -Encoding UTF8

Write-Host "============================================================"
Write-Host "SETTINGS BASELINE SUMMARY"
Write-Host "============================================================"
Write-Host "JSON files:            $($JsonFiles.Count)"
Write-Host "JSON failures:         $JsonFailures"
Write-Host "Lua strings:           $($LuaStrings.Count)"
Write-Host "REDscript files:       $($RedscriptRecords.Count)"
Write-Host "Missing REDscript:     $MissingRedscriptFiles"
Write-Host "Trusted commit:        $Commit"
Write-Host "Baseline:              $BaselinePath"
Write-Host "============================================================"

if ($JsonFailures -gt 0 -or $MissingRedscriptFiles -gt 0) {
    Write-Host "[FAIL] Settings baseline is incomplete."
    exit 1
}

Write-Host "[PASS] Exact SPLAT settings baseline created."
exit 0