[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MappingPath
)

$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $MappingPath).Path
$lines = Get-Content -LiteralPath $resolved
$required = @(
    'Request intent',
    'Timed pin driving',
    'Passive observation',
    'Independent prediction',
    'Correctness checking',
    'Scenario coverage',
    'Test orchestration and termination'
)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($name in $required) {
    $row = $lines | Where-Object { $_ -match ('^\|\s*' + [regex]::Escape($name) + '\s*\|') } | Select-Object -First 1
    if (-not $row) {
        $errors.Add("Missing mapping row: $name")
        continue
    }
    $columns = $row.Split('|') | ForEach-Object { $_.Trim() }
    if ($columns.Count -lt 6 -or [string]::IsNullOrWhiteSpace($columns[3]) -or $columns[3] -match 'TODO') {
        $errors.Add("Missing proposed UVM responsibility for: $name")
    }
    if ($columns.Count -lt 6 -or [string]::IsNullOrWhiteSpace($columns[4]) -or $columns[4] -match 'TODO') {
        $errors.Add("Missing boundary explanation for: $name")
    }
}

$predictionAnswers = $lines | Where-Object { $_ -match '^\s*-\s+' -and $_ -notmatch 'TODO' }
if ($predictionAnswers.Count -lt 2) {
    $errors.Add('Both prediction answers must be completed.')
}

if ($errors.Count -gt 0) {
    foreach ($errorMessage in $errors) {
        Write-Error $errorMessage -ErrorAction Continue
    }
    Write-Host "MAP_RESULT: FAIL errors=$($errors.Count)"
    exit 1
}

Write-Host "MAP_RESULT: PASS rows=$($required.Count) predictions=2"
exit 0
