[CmdletBinding()]
param(
    [string]$Test = 'tcs_smoke_test',
    [int]$Seed = 1,
    [ValidateSet('', 'F1')]
    [string]$Fault = '',
    [switch]$Reference,
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$dutSource = if ($Fault -eq 'F1') {
    Join-Path $moduleDirectory 'tests\faults\f1\tcs_peripheral.sv'
} else {
    Join-Path $moduleDirectory 'dut\tcs_peripheral.sv'
}

if ($Reference) {
    $sources = @(
        (Join-Path $moduleDirectory 'dut\tcs_if.sv'),
        $dutSource,
        (Join-Path $moduleDirectory 'tests\reference\reference_top.sv')
    )
    $top = 'reference_top'
    $snapshot = 'dvc1_reference_snapshot'
    $testName = 'dvc1_reference'
} else {
    # Learner: add package files here in dependency order before dvc1_tb_pkg.sv.
    $sources = @(
        (Join-Path $moduleDirectory 'dut\tcs_if.sv'),
        $dutSource,
        (Join-Path $moduleDirectory 'tb\dvc1_tb_pkg.sv'),
        (Join-Path $moduleDirectory 'tb\tb_top.sv')
    )
    $top = 'tb_top'
    $snapshot = 'dvc1_snapshot'
    $testName = $Test
}

& $runner -ModuleId 'DV-C1' -ModuleDirectory $moduleDirectory -Sources $sources `
    -Top $top -Snapshot $snapshot -Test $testName -Seed $Seed `
    -FunctionalCoverageReport:$(-not $Reference) -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
