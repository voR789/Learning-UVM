[CmdletBinding()]
param(
    [ValidateSet('ua03_copy_test')]
    [string]$Test = 'ua03_copy_test',
    [int]$Seed = 1,
    [string]$PackagePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $moduleDirectory 'tb\ua03_pkg.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Resolve-Path -LiteralPath $PackagePath).Path,
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner -ModuleId 'UA-03' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'tb_top' -Snapshot 'ua03_snapshot' -Test $Test -Seed $Seed `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
