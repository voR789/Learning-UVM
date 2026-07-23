[CmdletBinding()]param([string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop'
$moduleDirectory=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner=Join-Path $moduleDirectory 'run.ps1'
$valid=Join-Path $PSScriptRoot 'fixtures\valid_ui06_pkg.sv'
$invalid=Join-Path $PSScriptRoot 'fixtures\invalid_misroute_ui06_pkg.sv'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -PackagePath $valid -Seed 1 -VivadoRoot $VivadoRoot
if($LASTEXITCODE-ne 0){throw 'Valid UI-06 fixture failed.'}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -PackagePath $invalid -Seed 1 -VivadoRoot $VivadoRoot
if($LASTEXITCODE-eq 0){throw 'Misroute UI-06 fixture passed unexpectedly.'}
Write-Output 'FIXTURE_RESULT: PASS valid=passed misroute=failed_as_intended'
exit 0
