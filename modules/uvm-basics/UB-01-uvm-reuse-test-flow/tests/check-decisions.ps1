[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$DecisionPath)

$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $DecisionPath).Path
$text = Get-Content -Raw -LiteralPath $resolved
$required = @(
  '## Block-level context',
  '## Subsystem context',
  '## Test-flow ownership',
  '## Reuse boundary',
  '- Agent mode:',
  '- Signal-driving owner:',
  '- Observation/checking path retained:',
  '- Test-specific policy:',
  '| Configuration before construction |',
  '| Structural construction |',
  '| Transaction connections |',
  '| Timed execution and termination |'
)

foreach ($marker in $required) {
  if (-not $text.Contains($marker)) {
    Write-Host "DECISION_RESULT: FAIL (missing '$marker')"
    exit 1
  }
}

if ($text -match '(?im)(:\s*TODO\s*$|\|\s*TODO\s*\||^TODO\s*$)') {
  Write-Host 'DECISION_RESULT: FAIL (unfinished decisions remain)'
  exit 1
}

Write-Host 'DECISION_RESULT: PASS (structure complete; semantic review required)'
exit 0
