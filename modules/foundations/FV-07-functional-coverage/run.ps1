[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @((Join-Path $moduleDirectory 'tb\coverage_lab.sv'))

& $runner `
    -ModuleId 'FV-07' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'coverage_lab' `
    -Snapshot 'fv07_snapshot' `
    -Test 'functional_coverage_test' `
    -Seed $Seed `
    -FunctionalCoverageReport `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
