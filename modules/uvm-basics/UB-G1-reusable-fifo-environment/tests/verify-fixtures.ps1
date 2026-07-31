[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference = 'Stop'
$module = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $module 'run.ps1'
$package = Join-Path $PSScriptRoot 'fixtures\valid_ub_g1_pkg.sv'

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $package `
  -DutPath (Join-Path $module 'dut\sync_fifo.sv') -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'Known-good UB-G1 fixture failed.' }

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Seed 1 -PackagePath $package `
  -DutPath (Join-Path $PSScriptRoot 'fixtures\invalid_sync_fifo.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'Faulty UB-G1 DUT unexpectedly passed.' }
$simulationLog = Join-Path $module 'build\simulation.log'
if (!(Select-String -LiteralPath $simulationLog -SimpleMatch '[UBG1_MISMATCH]' -Quiet)) {
  throw 'Faulty UB-G1 DUT failed for an unexpected reason.'
}
Write-Host 'FIXTURE_RESULT: PASS (known-good passed; early-full DUT failed)'
