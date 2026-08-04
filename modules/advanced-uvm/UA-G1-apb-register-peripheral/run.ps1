[CmdletBinding()]
param(
    [ValidateSet('ua_g1_test')]
    [string]$Test = 'ua_g1_test',
    [int]$Seed = 1,
    [string]$PackagePath = '',
    [string]$DutPath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $moduleDirectory 'tb\ua_g1_pkg.sv'
}
if ([string]::IsNullOrWhiteSpace($DutPath)) {
    $DutPath = Join-Path $moduleDirectory 'dut\apb_math_peripheral.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\apb_if.sv'),
    (Resolve-Path -LiteralPath $DutPath).Path,
    (Join-Path $moduleDirectory 'tb\ua_g1_support_pkg.sv'),
    (Resolve-Path -LiteralPath $PackagePath).Path,
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner -ModuleId 'UA-G1' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'tb_top' -Snapshot 'ua_g1_snapshot' -Test $Test -Seed $Seed `
    -FunctionalCoverageReport -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
