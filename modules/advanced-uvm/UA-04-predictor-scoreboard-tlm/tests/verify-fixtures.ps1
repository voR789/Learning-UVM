[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua04_valid_fixture_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'UA-04 valid fixture failed.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua04_corrupt_actual_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-04 corrupt-actual fixture passed unexpectedly.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua04_learner_corrupt_actual_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-04 learner corrupt-actual test passed unexpectedly.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
    (Join-Path $moduleDirectory 'run.ps1') -Test 'ua04_test' -Seed 1 `
    -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-04 learner starter passed unexpectedly.' }

Write-Output 'FIXTURE_RESULT: PASS valid=passed corrupt_actual=failed learner_corrupt=failed starter=failed'
exit 0
