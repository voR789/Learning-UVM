[CmdletBinding()]
param(
    [ValidateSet('dv03_test')]
    [string]$Test = 'dv03_test',
    [int]$Seed = 1,
    [string]$TargetPackagePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($TargetPackagePath)) {
    $TargetPackagePath = Join-Path $moduleDirectory 'tb\dv03_target_pkg.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\dv03_support_pkg.sv'),
    (Resolve-Path -LiteralPath $TargetPackagePath).Path,
    (Join-Path $moduleDirectory 'tb\dv03_test_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner -ModuleId 'DV-03' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'tb_top' -Snapshot 'dv03_snapshot' -Test $Test -Seed $Seed `
    -FunctionalCoverageReport -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
