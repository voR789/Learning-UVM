[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$module = $PSScriptRoot
$uiG1 = (Resolve-Path -LiteralPath (Join-Path $module '..\..\uvm-introduction\UI-G1-programmable-counter-integration')).Path
$runner = Join-Path $uiG1 'run.ps1'

& powershell -NoProfile -ExecutionPolicy Bypass -File $runner `
  -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
