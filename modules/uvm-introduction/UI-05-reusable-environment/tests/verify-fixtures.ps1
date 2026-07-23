[CmdletBinding()]param([string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop'
$moduleDirectory=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner=Join-Path $moduleDirectory 'run.ps1'
$valid=Join-Path $PSScriptRoot 'fixtures\valid_ui05_pkg.sv'
$invalid=Join-Path $PSScriptRoot 'fixtures\invalid_always_driver_pkg.sv'
foreach($test in @('ui05_active_test','ui05_passive_test')){& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Test $test -PackagePath $valid -Seed 1 -VivadoRoot $VivadoRoot;if($LASTEXITCODE-ne 0){throw "Valid fixture failed: $test"}}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -Test ui05_passive_test -PackagePath $invalid -Seed 1 -VivadoRoot $VivadoRoot
if($LASTEXITCODE-eq 0){throw 'Always-driver fault passed passive mode unexpectedly.'}
Write-Output 'FIXTURE_RESULT: PASS active=passed passive=passed always_driver=failed_as_intended'
exit 0
