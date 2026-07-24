[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$PackagePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)
$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $moduleDirectory 'tb\ui10_pkg.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
& (Join-Path $repositoryRoot 'scripts\run-xsim.ps1') `
    -ModuleId UI-10 `
    -ModuleDirectory $moduleDirectory `
    -Sources @((Resolve-Path -LiteralPath $PackagePath).Path,
               (Join-Path $moduleDirectory 'tb\tb_top.sv')) `
    -Top tb_top `
    -Snapshot ui10_snapshot `
    -Test ui10_test `
    -Seed $Seed `
    -FunctionalCoverageReport `
    -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
