[CmdletBinding()]
param(
  [int]$Seed = 1,
  [string]$PackagePath = '',
  [string]$DutPath = '',
  [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)
$ErrorActionPreference = 'Stop'
$module = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
  $PackagePath = Join-Path $module 'tb\ub_g1_pkg.sv'
}
if ([string]::IsNullOrWhiteSpace($DutPath)) {
  $DutPath = Join-Path $module 'dut\sync_fifo.sv'
}
$repository = (Resolve-Path -LiteralPath (Join-Path $module '..\..\..')).Path
$sources = @(
  (Join-Path $module 'tb\fifo_if.sv'),
  (Resolve-Path -LiteralPath $DutPath).Path,
  (Resolve-Path -LiteralPath $PackagePath).Path,
  (Join-Path $module 'tb\tb_top.sv')
)
& (Join-Path $repository 'scripts\run-xsim.ps1') `
  -ModuleId 'UB-G1' -ModuleDirectory $module -Sources $sources `
  -Top 'tb_top' -Snapshot 'ub_g1_snapshot' -Test 'fifo_test' -Seed $Seed `
  -FunctionalCoverageReport -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
