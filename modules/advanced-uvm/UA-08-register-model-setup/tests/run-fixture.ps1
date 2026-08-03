[CmdletBinding()]
param(
    [ValidateSet('ua08_reference_test', 'ua08_wrong_offset_test')]
    [string]$Test,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua08_support_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\ua08_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\ral_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $runner -ModuleId 'UA-08' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua08_fixture_snapshot' -Test $Test -Seed 1 `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
