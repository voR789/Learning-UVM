[CmdletBinding()]
param(
    [ValidateSet('ua07_smoke_test', 'ua07_stress_test')]
    [string]$Test = 'ua07_smoke_test',
    [int]$Seed = 1,
    [string]$TestsPackagePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($TestsPackagePath)) {
    $TestsPackagePath = Join-Path $moduleDirectory 'tb\ua07_tests_pkg.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua07_support_pkg.sv'),
    (Resolve-Path -LiteralPath $TestsPackagePath).Path,
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner -ModuleId 'UA-07' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'tb_top' -Snapshot 'ua07_snapshot' -Test $Test -Seed $Seed `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
