[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua06_valid_fixture_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'UA-06 valid fixture failed.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua06_missing_data_handle_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-06 missing-data-handle fixture passed unexpectedly.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
    (Join-Path $moduleDirectory 'run.ps1') -Test 'ua06_test' -Seed 1 `
    -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-06 learner starter passed unexpectedly.' }

Write-Output 'FIXTURE_RESULT: PASS valid=passed missing_handle=failed starter=failed'
exit 0
