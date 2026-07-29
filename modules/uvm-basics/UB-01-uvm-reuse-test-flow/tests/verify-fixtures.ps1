[CmdletBinding()]
param([string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$module = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $module 'run.ps1'

& $runner -DecisionPath (Join-Path $PSScriptRoot 'fixtures\valid-reuse-decisions.md') `
  -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
  throw 'Valid UB-01 fixture failed.'
}

& (Join-Path $PSScriptRoot 'check-decisions.ps1') `
  -DecisionPath (Join-Path $PSScriptRoot 'fixtures\invalid-reuse-decisions.md')
if ($LASTEXITCODE -eq 0) {
  throw 'Invalid UB-01 fixture unexpectedly passed.'
}

Write-Host 'FIXTURE_RESULT: PASS (valid passed; incomplete decisions failed)'
