[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'dut\sync_fifo.sv'),
    (Join-Path $moduleDirectory 'tb\fifo_tb.sv')
)

& $runner `
    -ModuleId 'FV-G1' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'fifo_tb' `
    -Snapshot 'fvg1_snapshot' `
    -Test 'fifo_foundations_integration' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
