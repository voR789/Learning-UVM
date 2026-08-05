[CmdletBinding()]
param(
    [ValidateSet('dv02_smoke_test', 'dv02_arithmetic_test', 'dv02_completion_test')]
    [string]$Test = 'dv02_smoke_test',
    [int]$Seed = 1,
    [string]$PackagePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $moduleDirectory 'tb\dv02_pkg.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Resolve-Path -LiteralPath $PackagePath).Path,
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner -ModuleId 'DV-02' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'tb_top' -Snapshot 'dv02_snapshot' -Test $Test -Seed $Seed `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
