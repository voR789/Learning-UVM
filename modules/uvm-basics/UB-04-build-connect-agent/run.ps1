[CmdletBinding()]
param(
  [int]$Seed = 1,
  [string]$PackagePath = '',
  [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$module = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
  $PackagePath = Join-Path $module 'tb\ub04_pkg.sv'
}
$repository = (Resolve-Path -LiteralPath (Join-Path $module '..\..\..')).Path
$runner = Join-Path $repository 'scripts\run-xsim.ps1'
$sources = @(
  $PackagePath,
  (Join-Path $module 'tb\ub04_check_pkg.sv'),
  (Join-Path $module 'tb\tb_top.sv')
)

foreach ($test in @('ub04_active_test', 'ub04_passive_test')) {
  & $runner -ModuleId 'UB-04' -ModuleDirectory $module -Sources $sources `
    -Top 'tb_top' -Snapshot 'ub04_snapshot' -Test $test -Seed $Seed `
    -VivadoRoot $VivadoRoot
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}
exit 0
