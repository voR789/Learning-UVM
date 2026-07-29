[CmdletBinding()]
param(
  [int]$Seed = 1,
  [string]$PackagePath = '',
  [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$module = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
  $PackagePath = Join-Path $module 'tb\ub06_pkg.sv'
}
$repository = (Resolve-Path -LiteralPath (Join-Path $module '..\..\..')).Path
$runner = Join-Path $repository 'scripts\run-xsim.ps1'
$sources = @(
  $PackagePath,
  (Join-Path $module 'tb\tb_top.sv')
)

& $runner -ModuleId 'UB-06' -ModuleDirectory $module -Sources $sources `
  -Top 'tb_top' -Snapshot 'ub06_snapshot' -Test 'ub06_test' -Seed $Seed `
  -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
