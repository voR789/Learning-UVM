[CmdletBinding()]
param(
    [ValidateSet(
        'ua07_reference_smoke_test',
        'ua07_reference_stress_test',
        'ua07_bypass_common_run_test'
    )]
    [string]$Test,
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua07_support_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\ua07_tests_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\hierarchy_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $runner -ModuleId 'UA-07' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua07_fixture_snapshot' -Test $Test -Seed $Seed `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
