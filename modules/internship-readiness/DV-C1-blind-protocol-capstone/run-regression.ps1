[CmdletBinding()]
param(
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
$runScript = Join-Path $moduleDirectory 'run.ps1'
$xcrg = Join-Path $VivadoRoot 'bin\xcrg.bat'
$coverageRuns = Join-Path $moduleDirectory 'coverage-runs'
$mergedDirectory = Join-Path $moduleDirectory 'coverage-merged'
$coverageName = 'dvc1_snapshot'

$matrix = @(
    @{ Test = 'tcs_reset_test';    Seed = 1 },
    @{ Test = 'tcs_reset_test';    Seed = 5 },
    @{ Test = 'tcs_op_test';       Seed = 1 },
    @{ Test = 'tcs_op_test';       Seed = 5 },
    @{ Test = 'tcs_protocol_test'; Seed = 1 },
    @{ Test = 'tcs_protocol_test'; Seed = 5 },
    @{ Test = 'tcs_stress_test';   Seed = 2 },
    @{ Test = 'tcs_stress_test';   Seed = 5 },
    @{ Test = 'tcs_stress_test';   Seed = 8 }
)

if (-not (Test-Path -LiteralPath $xcrg -PathType Leaf)) {
    throw "XSim coverage tool not found: $xcrg"
}

foreach ($directory in @($coverageRuns, $mergedDirectory)) {
    if (Test-Path -LiteralPath $directory) {
        Remove-Item -LiteralPath $directory -Recurse -Force
    }
}
New-Item -ItemType Directory -Path $coverageRuns | Out-Null

$savedDatabases = @()
foreach ($entry in $matrix) {
    $label = '{0}-seed{1}' -f $entry.Test, $entry.Seed
    Write-Host "[DV-C1] Regression: $label"
    & $runScript -Test $entry.Test -Seed $entry.Seed -VivadoRoot $VivadoRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Regression run failed: $label"
    }

    $sourceDatabase = Join-Path $moduleDirectory "build\xsim.covdb\$coverageName"
    if (-not (Test-Path -LiteralPath $sourceDatabase -PathType Container)) {
        throw "Coverage database missing after ${label}: $sourceDatabase"
    }

    $runDirectory = Join-Path $coverageRuns $label
    New-Item -ItemType Directory -Path $runDirectory | Out-Null
    Copy-Item -LiteralPath (Join-Path $moduleDirectory 'build\xsim.covdb') -Destination $runDirectory -Recurse
    $savedDatabases += $runDirectory
}

$mergeArguments = @()
foreach ($databaseDirectory in $savedDatabases) {
    $mergeArguments += @('-cov_db_dir', $databaseDirectory, '-cov_db_name', $coverageName)
}
$mergeArguments += @(
    '-merge_dir', $mergedDirectory,
    '-merge_db_name', 'dvc1_regression',
    '-report_dir', (Join-Path $mergedDirectory 'report'),
    '-report_format', 'all',
    '-nolog'
)

Write-Host '[DV-C1] Merging functional coverage databases'
& $xcrg @mergeArguments
if ($LASTEXITCODE -ne 0) {
    throw 'Functional coverage merge failed.'
}

Write-Host "[DV-C1] Merged coverage report: $(Join-Path $mergedDirectory 'report')"
