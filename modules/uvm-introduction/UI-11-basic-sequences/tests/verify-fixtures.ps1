[CmdletBinding()]
param([string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop'
$m=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner=Join-Path $m 'run.ps1'
$valid=Join-Path $PSScriptRoot 'fixtures\valid_ui11_pkg.sv'
$invalid=Join-Path $PSScriptRoot 'fixtures\invalid_missing_child_ui11_pkg.sv'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $valid -VivadoRoot $VivadoRoot
if($LASTEXITCODE-ne 0){throw 'UI-11 valid fixture must pass.'}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $invalid -VivadoRoot $VivadoRoot
if($LASTEXITCODE-eq 0){throw 'UI-11 missing-child fixture must fail.'}
$log=Get-Content -Raw -LiteralPath (Join-Path $m 'build\simulation.log')
if($log-notmatch 'UI-11 timeout'){throw 'UI-11 fault fixture failed for an unexpected reason.'}
Write-Host '[UI-11] FIXTURE_RESULT: PASS (valid composition accepted; missing child timed out)'
exit 0
