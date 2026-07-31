[CmdletBinding()]
param(
    [ValidateSet('ua04_valid_fixture_test', 'ua04_corrupt_actual_test')]
    [string]$Test,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua04_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\flow_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $runner -ModuleId 'UA-04' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua04_fixture_snapshot' -Test $Test -Seed 1 `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
