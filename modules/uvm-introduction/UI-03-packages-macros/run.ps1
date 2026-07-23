[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$PackagePath = '',
    [switch]$ReverseOrder,
    [switch]$SkipMapCheck,
    [string]$MapPath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $moduleDirectory 'tb\ui03_pkg.sv'
}
$topPath = Join-Path $moduleDirectory 'tb\tb_top.sv'
$sources = @((Resolve-Path -LiteralPath $PackagePath).Path, $topPath)
if ($ReverseOrder) {
    $sources = @($topPath, (Resolve-Path -LiteralPath $PackagePath).Path)
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
if ([string]::IsNullOrWhiteSpace($MapPath)) {
    $MapPath = Join-Path $moduleDirectory 'exercise\syntax-map.md'
}

& $runner `
    -ModuleId 'UI-03' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'tb_top' `
    -Snapshot 'ui03_snapshot' `
    -Test 'package_macro_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not $SkipMapCheck) {
    & (Join-Path $moduleDirectory 'tests\check-syntax-map.ps1') -MapPath $MapPath
    exit $LASTEXITCODE
}

exit 0
