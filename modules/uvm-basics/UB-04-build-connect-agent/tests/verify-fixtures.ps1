[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$module = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $module 'run.ps1'

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\valid_ub04_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
  throw 'Valid UB-04 fixture failed.'
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\invalid_ub04_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
  throw 'Invalid UB-04 fixture unexpectedly passed.'
}

Write-Host 'FIXTURE_RESULT: PASS (valid modes passed; passive driving topology failed)'
