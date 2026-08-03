[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua10_reference_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'UA-10 reference fixture failed.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua10_alias_memory_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-10 alias-memory fixture passed unexpectedly.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
    (Join-Path $moduleDirectory 'run.ps1') -Test 'ua10_test' -Seed 1 `
    -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'UA-10 learner starter passed unexpectedly.' }

Write-Output 'FIXTURE_RESULT: PASS reference=passed alias_memory=failed starter=failed'
exit 0
