[CmdletBinding()]
param(
  [int]$Seed = 1,
  [string]$PackagePath = '',
  [string]$SingleTest = '',
  [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$module = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
  $PackagePath = Join-Path $module 'tb\ub08_pkg.sv'
}
$PackagePath = (Resolve-Path -LiteralPath $PackagePath).Path

if ([string]::IsNullOrWhiteSpace($SingleTest)) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath `
    -Seed $Seed -PackagePath $PackagePath -SingleTest 'ub08_clean_test' `
    -VivadoRoot $VivadoRoot
  if ($LASTEXITCODE -ne 0) {
    throw 'UB-08 clean run failed.'
  }
  $cleanLog = Get-Content -LiteralPath (Join-Path $module 'build\simulation.log') -Raw
  if ($cleanLog -notmatch '\[UB08_SUMMARY\].*checked=5 mismatches=0') {
    throw 'UB-08 clean run omitted the required final summary.'
  }

  & powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath `
    -Seed $Seed -PackagePath $PackagePath -SingleTest 'ub08_fault_test' `
    -VivadoRoot $VivadoRoot
  if ($LASTEXITCODE -eq 0) {
    throw 'UB-08 injected fault unexpectedly passed.'
  }
  $faultLog = Get-Content -LiteralPath (Join-Path $module 'build\simulation.log') -Raw
  if ($faultLog -notmatch '\[UB08_MISMATCH\].*seed=[0-9]+.*id=3.*expected=0x[0-9a-fA-F]+.*observed=0x[0-9a-fA-F]+') {
    throw 'UB-08 fault failed without complete mismatch context.'
  }
  if ($faultLog -notmatch '\[UB08_SUMMARY\].*checked=5 mismatches=1') {
    throw 'UB-08 fault run omitted the required final summary.'
  }
  Write-Host 'MODULE_RESULT: PASS (clean passed; injected mismatch was diagnosed)'
  exit 0
}

$repository = (Resolve-Path -LiteralPath (Join-Path $module '..\..\..')).Path
$runner = Join-Path $repository 'scripts\run-xsim.ps1'
$sources = @(
  $PackagePath,
  (Join-Path $module 'tb\ub08_check_pkg.sv'),
  (Join-Path $module 'tb\tb_top.sv')
)

& $runner -ModuleId 'UB-08' -ModuleDirectory $module -Sources $sources `
  -Top 'tb_top' -Snapshot 'ub08_snapshot' -Test $SingleTest -Seed $Seed `
  -TestPlusargs @("UB08_SEED=$Seed") `
  -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
