[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'dut\registered_adder.sv'),
    (Join-Path $moduleDirectory 'tb\sync_if.sv'),
    (Join-Path $moduleDirectory 'tb\concurrency_lab.sv')
)

& $runner `
    -ModuleId 'FV-06' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'concurrency_lab' `
    -Snapshot 'fv06_snapshot' `
    -Test 'concurrent_sync_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
