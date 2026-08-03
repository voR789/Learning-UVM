[CmdletBinding()]
param(
    [ValidateSet('ua08_test')]
    [string]$Test = 'ua08_test',
    [int]$Seed = 1,
    [string]$PackagePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $moduleDirectory 'tb\ua08_pkg.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ua08_support_pkg.sv'),
    (Resolve-Path -LiteralPath $PackagePath).Path,
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner -ModuleId 'UA-08' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'tb_top' -Snapshot 'ua08_snapshot' -Test $Test -Seed $Seed `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
