[CmdletBinding()]
param(
    [string]$Test = 'smoke_pass_test',
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources = @(
    (Join-Path $moduleDirectory 'dut\smoke_counter.sv'),
    (Join-Path $moduleDirectory 'tb\smoke_if.sv'),
    (Join-Path $moduleDirectory 'tb\smoke_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\tb_top.sv')
)

& $runner `
    -ModuleId 'FV-00' `
    -ModuleDirectory $moduleDirectory `
    -Sources $sources `
    -Top 'tb_top' `
    -Snapshot 'fv00_snapshot' `
    -Test $Test `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE

