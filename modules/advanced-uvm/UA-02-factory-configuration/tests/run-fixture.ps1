[CmdletBinding()]
param(
    [ValidateSet('ua02_valid_type_test', 'ua02_valid_instance_test', 'ua02_wrong_path_test')]
    [string]$Test,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$sharedRunner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua02_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixtures\override_fixture_pkg.sv'),
    (Join-Path $PSScriptRoot 'fixture_top.sv')
)

& $sharedRunner -ModuleId 'UA-02' -ModuleDirectory $moduleDirectory `
    -Sources $sources -Top 'fixture_top' -Snapshot 'ua02_fixture_snapshot' `
    -Test $Test -Seed 1 -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
