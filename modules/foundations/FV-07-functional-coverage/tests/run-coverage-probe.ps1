[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$source = Join-Path $PSScriptRoot 'xsim-coverage-probe.sv'

& $runner `
    -ModuleId 'FV-07-PROBE' `
    -ModuleDirectory $moduleDirectory `
    -Sources @($source) `
    -Top 'xsim_coverage_probe' `
    -Snapshot 'fv07_probe_snapshot' `
    -Test 'coverage_probe' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
