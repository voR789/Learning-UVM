[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner = Join-Path $moduleDirectory 'run.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid_ui03_pkg.sv'
$validMap = Join-Path $PSScriptRoot 'fixtures\valid-syntax-map.md'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -PackagePath $valid -SkipMapCheck -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'Valid package fixture did not pass.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -PackagePath $valid -ReverseOrder -SkipMapCheck -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'Reversed compile order passed unexpectedly.' }

& (Join-Path $PSScriptRoot 'check-syntax-map.ps1') -MapPath $validMap
if ($LASTEXITCODE -ne 0) { throw 'Valid syntax-map fixture did not pass.' }

Write-Output 'FIXTURE_RESULT: PASS valid=passed reverse_order=failed_as_intended map=passed'
exit 0
