[CmdletBinding()]
param(
    [ValidateSet('ua03_valid_fixture_test', 'ua03_extension_loss_test')]
    [string]$Test,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua03_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\transaction_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $runner -ModuleId 'UA-03' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua03_fixture_snapshot' -Test $Test -Seed 1 `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
