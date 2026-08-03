[CmdletBinding()]
param(
    [ValidateSet('ua09_reference_test', 'ua09_predict_without_observation_test')]
    [string]$Test,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua09_support_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\ua09_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\access_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $runner -ModuleId 'UA-09' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua09_fixture_snapshot' -Test $Test -Seed 1 `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
