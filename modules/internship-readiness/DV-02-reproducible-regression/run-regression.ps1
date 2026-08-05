[CmdletBinding()]
param(
    [string]$MatrixPath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($MatrixPath)) {
    $MatrixPath = Join-Path $moduleDirectory 'plan\regression-matrix.csv'
}
$resolvedMatrix = (Resolve-Path -LiteralPath $MatrixPath).Path
$rows = @(Import-Csv -LiteralPath $resolvedMatrix)
if ($rows.Count -eq 0) {
    throw 'Regression matrix contains no runs.'
}

$reportsDirectory = Join-Path $moduleDirectory 'reports'
$logsDirectory = Join-Path $reportsDirectory 'run-logs'
New-Item -ItemType Directory -Path $logsDirectory -Force | Out-Null
$results = @()
$failed = 0

foreach ($row in $rows) {
    $test = [string]$row.test
    $seed = [int]$row.seed
    $runName = '{0}-seed-{1}' -f $test, $seed
    $consoleLog = Join-Path $logsDirectory ($runName + '.log')
    Write-Host "[DV-02 REGRESSION] RUN test=$test seed=$seed"

    $savedErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass `
            -File (Join-Path $moduleDirectory 'run.ps1') `
            -Test $test -Seed $seed -VivadoRoot $VivadoRoot `
            2>&1 | Tee-Object -FilePath $consoleLog
        $runExit = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $savedErrorPreference
    }
    $status = if ($runExit -eq 0) { 'PASS' } else { 'FAIL' }
    if ($runExit -ne 0) {
        $failed++
    }

    $signature = ''
    $signatureLine = Select-String -LiteralPath $consoleLog `
        -Pattern '\[(DV02_DATA|DV02_MISSING|DV02_RESULT)\]' |
        Select-Object -First 1
    if ($null -ne $signatureLine) {
        $signature = $signatureLine.Line.Trim()
    }
    $results += [pscustomobject]@{
        test = $test
        seed = $seed
        status = $status
        exit_code = $runExit
        first_signature = $signature
        log = "reports/run-logs/$runName.log"
    }
}

$resultsPath = Join-Path $reportsDirectory 'latest-results.csv'
$results | Export-Csv -LiteralPath $resultsPath -NoTypeInformation
Write-Host "[DV-02 REGRESSION] COMPLETE runs=$($rows.Count) failed=$failed"
Write-Host "[DV-02 REGRESSION] RESULTS $resultsPath"
if ($failed -ne 0) {
    exit 1
}
exit 0
