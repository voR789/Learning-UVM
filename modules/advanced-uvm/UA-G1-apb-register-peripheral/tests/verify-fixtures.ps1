[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test ua_g1_reference_test -Seed $Seed -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
    throw 'UA-G1 reference fixture did not pass.'
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test ua_g1_fault_test -Seed $Seed -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'UA-G1 faulty DUT unexpectedly passed.'
}

Write-Output 'FIXTURE_RESULT: PASS reference=passed faulty_result=failed'
