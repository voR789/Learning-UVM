[CmdletBinding()]
param(
    [int]$Seed = 2025,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$runScript = Join-Path $PSScriptRoot '..\run.ps1'
$powershell = Join-Path $PSHOME 'powershell.exe'

Write-Host '[FV-00] Verifying known-pass test'
& $powershell -NoProfile -ExecutionPolicy Bypass -File $runScript `
    -Test 'smoke_pass_test' -Seed $Seed -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
    throw 'Known-pass test failed.'
}

Write-Host '[FV-00] Verifying deliberate UVM failure detection'
& $powershell -NoProfile -ExecutionPolicy Bypass -File $runScript `
    -Test 'smoke_expected_fail_test' -Seed $Seed -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'Runner incorrectly accepted the deliberate UVM failure.'
}

Write-Host '[FV-00] RUNNER SELF-TEST: PASS'
exit 0
