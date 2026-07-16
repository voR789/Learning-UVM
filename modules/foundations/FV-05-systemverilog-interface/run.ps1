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
    (Join-Path $moduleDirectory 'tb\alu_if.sv'),
    (Join-Path $moduleDirectory 'tb\interface_lab.sv')
)

& $runner `
    -ModuleId 'FV-05' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'interface_lab' `
    -Snapshot 'fv05_snapshot' `
    -Test 'interface_connection_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
