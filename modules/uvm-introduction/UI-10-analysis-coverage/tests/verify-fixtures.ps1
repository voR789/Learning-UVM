[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner = Join-Path $moduleDirectory 'run.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid_ui10_pkg.sv'
$invalid = Join-Path $PSScriptRoot 'fixtures\invalid_missing_cross_ui10_pkg.sv'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $valid -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'UI-10 valid fixture must pass.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $invalid -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UI-10 missing-cross fixture must fail.' }
$simulationLog = Join-Path $moduleDirectory 'build\simulation.log'
$simulationText = Get-Content -Raw -LiteralPath $simulationLog
if (($simulationText -notmatch 'UI10_COVERAGE') -or
    ($simulationText -notmatch 'missing required cross combination')) {
    throw 'UI-10 fault fixture failed for an unexpected reason.'
}
Write-Host '[UI-10] FIXTURE_RESULT: PASS (valid closure accepted; missing cross combination rejected)'
exit 0
