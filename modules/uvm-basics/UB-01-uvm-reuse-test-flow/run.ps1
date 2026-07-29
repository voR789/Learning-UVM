[CmdletBinding()]
param(
  [int]$Seed = 1,
  [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$module = $PSScriptRoot
$repository = (Resolve-Path -LiteralPath (Join-Path $module '..\..\..')).Path
$runner = Join-Path $repository 'scripts\run-xsim.ps1'
$sources = @(
  (Join-Path $module 'tb\ub01_pkg.sv'),
  (Join-Path $module 'tb\tb_top.sv')
)

foreach ($test in @('ub01_active_test', 'ub01_passive_test')) {
  & $runner -ModuleId 'UB-01' -ModuleDirectory $module -Sources $sources `
    -Top 'tb_top' -Snapshot 'ub01_snapshot' -Test $test -Seed $Seed `
    -VivadoRoot $VivadoRoot
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}
exit 0
