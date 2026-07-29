[CmdletBinding()]
param([string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$module = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $module 'run.ps1'

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\valid_ub02_pkg.sv') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
  throw 'Valid UB-02 fixture failed.'
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -PackagePath (Join-Path $PSScriptRoot 'fixtures\invalid_ub02_pkg.sv') `
  -VivadoRoot $VivadoRoot
$invalidExitCode = $LASTEXITCODE
if ($invalidExitCode -eq 0) {
  throw 'Invalid UB-02 fixture unexpectedly passed.'
}

Write-Host 'FIXTURE_RESULT: PASS (valid passed; missing worker failed)'
