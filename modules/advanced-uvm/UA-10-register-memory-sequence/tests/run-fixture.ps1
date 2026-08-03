[CmdletBinding()]
param(
    [ValidateSet('ua10_reference_test', 'ua10_alias_memory_test')]
    [string]$Test,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua10_support_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\ua10_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\memory_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $runner -ModuleId 'UA-10' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua10_fixture_snapshot' -Test $Test -Seed 1 `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
