[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'

foreach ($row in @(
    @{ Test = 'ua07_reference_smoke_test'; Seed = 1 },
    @{ Test = 'ua07_reference_stress_test'; Seed = 1 },
    @{ Test = 'ua07_reference_stress_test'; Seed = 17 }
)) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
        -Test $row.Test -Seed $row.Seed -VivadoRoot $VivadoRoot
    if ($LASTEXITCODE -ne 0) {
        throw "UA-07 valid fixture failed: test=$($row.Test) seed=$($row.Seed)"
    }
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua07_bypass_common_run_test' -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'UA-07 bypass-common-run fixture passed unexpectedly.'
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
    (Join-Path $moduleDirectory 'run.ps1') -Test 'ua07_smoke_test' -Seed 1 `
    -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'UA-07 learner starter passed unexpectedly.'
}

Write-Output 'FIXTURE_RESULT: PASS valid=3 bypass_common_run=failed starter=failed'
exit 0
