[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'dut\alu.sv'),
    (Join-Path $moduleDirectory 'tb\alu_tb.sv')
)

& $runner `
    -ModuleId 'FV-02' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'alu_tb' `
    -Snapshot 'fv02_snapshot' `
    -Test 'directed_alu_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
