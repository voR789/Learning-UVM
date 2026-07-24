[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner = Join-Path $moduleDirectory 'run.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid_ui09_pkg.sv'
$invalid = Join-Path $PSScriptRoot 'fixtures\invalid_error_with_pass_ui09_pkg.sv'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $valid -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'UI-09 valid fixture must pass.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $invalid -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UI-09 error-with-pass-marker fixture must fail.' }
$simulationLog = Join-Path $moduleDirectory 'build\simulation.log'
$simulationText = Get-Content -Raw -LiteralPath $simulationLog
if (($simulationText -notmatch 'UI09_MISMATCH') -or
    ($simulationText -notmatch '(?m)^TEST_RESULT:\s*PASS\s*$') -or
    ($simulationText -notmatch '(?m)^UVM_ERROR\s*:\s*1\s*$')) {
    throw 'UI-09 fault fixture failed for an unexpected reason.'
}
Write-Host '[UI-09] FIXTURE_RESULT: PASS (valid accepted; pass marker with UVM error rejected)'
exit 0
