[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner = Join-Path $moduleDirectory 'run.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid_ui04_pkg.sv'
$invalid = Join-Path $PSScriptRoot 'fixtures\invalid_parent_ui04_pkg.sv'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -PackagePath $valid -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) { throw 'Valid UI-04 hierarchy fixture did not pass.' }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -PackagePath $invalid -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) { throw 'Wrong-parent UI-04 fixture passed unexpectedly.' }

Write-Output 'FIXTURE_RESULT: PASS valid=passed wrong_parent=failed_as_intended'
exit 0
