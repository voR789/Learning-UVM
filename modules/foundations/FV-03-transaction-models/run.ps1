[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @((Join-Path $moduleDirectory 'tb\transaction_lab.sv'))

& $runner `
    -ModuleId 'FV-03' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'transaction_lab' `
    -Snapshot 'fv03_snapshot' `
    -Test 'transaction_model_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
