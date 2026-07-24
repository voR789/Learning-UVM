[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner = Join-Path $moduleDirectory 'run.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid_ui08_pkg.sv'
$invalid = Join-Path $PSScriptRoot 'fixtures\invalid_missing_audit_ui08_pkg.sv'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner `
    -Seed 1 -PackagePath $valid -VivadoRoot $VivadoRoot
$validExitCode = $LASTEXITCODE
if ($validExitCode -ne 0) {
    throw 'UI-08 valid fixture must pass.'
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner `
    -Seed 1 -PackagePath $invalid -VivadoRoot $VivadoRoot
$invalidExitCode = $LASTEXITCODE
if ($invalidExitCode -eq 0) {
    throw 'UI-08 missing-audit fixture must fail.'
}
$simulationLog = Join-Path $moduleDirectory 'build\simulation.log'
$simulationText = Get-Content -Raw -LiteralPath $simulationLog
if ($simulationText -notmatch 'expected 3/3/3 got 3/3/0') {
    throw 'UI-08 fault fixture failed for an unexpected reason.'
}
Write-Host '[UI-08] FIXTURE_RESULT: PASS (valid accepted; missing audit rejected as 3/3/0)'
exit 0
