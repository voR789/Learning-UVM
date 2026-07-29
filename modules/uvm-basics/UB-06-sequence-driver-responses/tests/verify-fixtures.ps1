[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$module = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $module 'run.ps1'

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\valid_ub06_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
  throw 'Valid UB-06 fixture failed.'
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\invalid_ub06_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
  throw 'Invalid UB-06 fixture unexpectedly passed.'
}
$simulationLog = Join-Path $module 'build\simulation.log'
$simulationText = Get-Content -LiteralPath $simulationLog -Raw
if ($simulationText -notmatch '\[UB06_RESPONSE\]') {
  throw 'Invalid UB-06 fixture failed for an unexpected reason.'
}

Write-Host 'FIXTURE_RESULT: PASS (valid passed; wrong response failed)'
