[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checker = Join-Path $PSScriptRoot 'check-plan.ps1'
$validPlan = Join-Path $PSScriptRoot 'fixtures\valid-plan.md'
$invalidPlan = Join-Path $PSScriptRoot 'fixtures\invalid-plan.md'

Write-Host '[FV-01] Verifying known-valid plan fixture'
& $checker -PlanPath $validPlan -RequiredRequirementIds @('REQ-A', 'REQ-B')

Write-Host '[FV-01] Verifying known-invalid plan fixture'
$rejected = $false
try {
    & $checker -PlanPath $invalidPlan -RequiredRequirementIds @('REQ-A', 'REQ-B')
} catch {
    $rejected = $true
    Write-Host '[FV-01] Expected rejection observed.'
}

if (-not $rejected) {
    throw 'Checker incorrectly accepted the invalid plan fixture.'
}

Write-Host '[FV-01] CHECKER SELF-TEST: PASS'
exit 0
