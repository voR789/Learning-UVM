[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$module = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $module 'run.ps1'

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\valid_ub08_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
  throw 'Valid UB-08 fixture failed.'
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\invalid_ub08_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
  throw 'Invalid UB-08 fixture unexpectedly passed.'
}

Write-Host 'FIXTURE_RESULT: PASS (valid diagnostics passed; silent mismatch reporting failed)'
