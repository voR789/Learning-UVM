[CmdletBinding()]
param(
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$ui05FixtureRunner = Join-Path $repositoryRoot 'modules\uvm-introduction\UI-05-reusable-environment\tests\verify-fixtures.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ui05FixtureRunner -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
    throw 'UA-01 checkpoint failed: prior active/passive architecture evidence did not reproduce.'
}

Write-Output 'UA01_CHECKPOINT: PASS active=valid passive=valid passive_driver=rejected'
exit 0
