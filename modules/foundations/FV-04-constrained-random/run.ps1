[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @((Join-Path $moduleDirectory 'tb\randomization_lab.sv'))

& $runner `
    -ModuleId 'FV-04' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'randomization_lab' `
    -Snapshot 'fv04_snapshot' `
    -Test 'constrained_random_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
