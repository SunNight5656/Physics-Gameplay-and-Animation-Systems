param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

Write-Host "Validating SPLAT package..."
& ".\scripts\validate-package.ps1"

if ($LASTEXITCODE -ne 0) {
    throw "Package validation failed."
}

$OutputDirectory = ".\dist"
$OutputFile = Join-Path $OutputDirectory "SPLAT-$Version.zip"

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
}

Compress-Archive `
    -Path ".\src\archive", ".\src\bin", ".\src\r6" `
    -DestinationPath $OutputFile `
    -CompressionLevel Optimal

Write-Host "Release package created:"
Write-Host $OutputFile