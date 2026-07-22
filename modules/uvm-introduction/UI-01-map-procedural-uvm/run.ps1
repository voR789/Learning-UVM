[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$MappingPath = $(Join-Path $PSScriptRoot 'exercise\architecture-map.md'),
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$checker = Join-Path $moduleDirectory 'tests\check-map.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'tb\ui01_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner `
    -ModuleId 'UI-01' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'tb_top' `
    -Snapshot 'ui01_snapshot' `
    -Test 'ui01_hierarchy_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& $checker -MappingPath $MappingPath
exit $LASTEXITCODE
