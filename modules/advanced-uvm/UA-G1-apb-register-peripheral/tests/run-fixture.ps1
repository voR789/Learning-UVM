[CmdletBinding()]
param(
    [ValidateSet('ua_g1_reference_test', 'ua_g1_fault_test')]
    [string]$Test = 'ua_g1_reference_test',
    [int]$Seed = 1,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$dutPath = Join-Path $moduleDirectory 'dut\apb_math_peripheral.sv'
if ($Test -eq 'ua_g1_fault_test') {
    $dutPath = Join-Path $moduleDirectory 'tests\fixtures\faulty_apb_math_peripheral.sv'
}
$sources = @(
    (Join-Path $moduleDirectory 'tb\apb_if.sv'),
    $dutPath,
    (Join-Path $moduleDirectory 'tb\ua_g1_support_pkg.sv'),
    (Join-Path $moduleDirectory 'tb\ua_g1_pkg.sv'),
    (Join-Path $moduleDirectory 'tests\fixtures\reference_pkg.sv'),
    (Join-Path $moduleDirectory 'tests\fixture_top.sv')
)

& $runner -ModuleId 'UA-G1' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top 'fixture_top' -Snapshot 'ua_g1_fixture_snapshot' -Test $Test `
    -Seed $Seed -FunctionalCoverageReport -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
