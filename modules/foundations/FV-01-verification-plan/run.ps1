[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$planPath = Join-Path $PSScriptRoot 'plan\verification-plan.md'
$checker = Join-Path $PSScriptRoot 'tests\check-plan.ps1'
$requirements = @(
    'REQ-ADD',
    'REQ-SUB',
    'REQ-AND',
    'REQ-OR',
    'REQ-XOR',
    'REQ-INVALID',
    'REQ-ZERO',
    'REQ-CARRY'
)

Write-Host '[FV-01] Checking verification-plan structure and traceability'

try {
    & $checker -PlanPath $planPath -RequiredRequirementIds $requirements
} catch {
    Write-Error "[FV-01] $($_.Exception.Message)"
    exit 1
}

Write-Host '[FV-01] Structural check passed; request semantic review against rubric.md.'
exit 0
