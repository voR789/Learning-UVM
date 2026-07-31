[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua03_valid_fixture_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'UA-03 valid fixture failed.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua03_extension_loss_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-03 extension-loss fixture passed unexpectedly.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
    (Join-Path $moduleDirectory 'run.ps1') -Test 'ua03_copy_test' -Seed 1 `
    -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-03 learner starter passed unexpectedly.' }

Write-Output 'FIXTURE_RESULT: PASS valid=passed extension_loss=failed starter=failed'
exit 0
