[CmdletBinding()]
param([string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop'
$module=Split-Path -Parent $PSScriptRoot
$runner=Join-Path $module 'run.ps1'
$package=Join-Path $PSScriptRoot 'fixtures\valid_ui_g1_pkg.sv'

& $runner -Seed 1 -PackagePath $package `
  -DutPath (Join-Path $module 'dut\counter.sv') -VivadoRoot $VivadoRoot
if($LASTEXITCODE -ne 0){throw 'Known-good UI-G1 fixture failed.'}

& $runner -Seed 1 -PackagePath $package `
  -DutPath (Join-Path $PSScriptRoot 'fixtures\invalid_counter.sv') -VivadoRoot $VivadoRoot
if($LASTEXITCODE -eq 0){throw 'Faulty UI-G1 DUT unexpectedly passed.'}
$simulationLog=Join-Path $module 'build\simulation.log'
if(!(Select-String -LiteralPath $simulationLog -SimpleMatch '[COUNT_MISMATCH]' -Quiet)){
  throw 'Faulty UI-G1 DUT failed for an unexpected reason.'
}

Write-Host 'FIXTURE_RESULT: PASS (known-good passed; faulty DUT failed)'
