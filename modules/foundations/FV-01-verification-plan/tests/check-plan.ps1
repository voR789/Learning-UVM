[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PlanPath,

    [Parameter(Mandatory = $true)]
    [string[]]$RequiredRequirementIds
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $PlanPath -PathType Leaf)) {
    throw "Plan file not found: $PlanPath"
}

$plan = Get-Content -LiteralPath $PlanPath -Raw
$problems = New-Object System.Collections.Generic.List[string]

foreach ($heading in @('Scope', 'Assumptions', 'Test cases', 'Completion criteria')) {
    if ($plan -notmatch "(?m)^##\s+$([regex]::Escape($heading))\s*$") {
        $problems.Add("Missing required heading: ## $heading")
    }
}

if ($plan -match '(?i)\bTODO\b|<\s*(fill|replace|answer)[^>]*>') {
    $problems.Add('The plan still contains an unresolved TODO or fill-in marker.')
}

$requiredColumns = @(
    'Test ID',
    'Requirement ID',
    'Test intent',
    'Stimulus',
    'Observations',
    'Expected result',
    'Failure criterion'
)

$headerLine = ($plan -split "`r?`n" | Where-Object { $_ -match '^\s*\|\s*Test ID\s*\|' } | Select-Object -First 1)
if (-not $headerLine) {
    $problems.Add('Missing the required test-case table header.')
} else {
    foreach ($column in $requiredColumns) {
        if ($headerLine -notmatch [regex]::Escape($column)) {
            $problems.Add("Missing required table column: $column")
        }
    }
}

foreach ($requirementId in $RequiredRequirementIds) {
    if ($plan -notmatch "(?m)\|[^`r`n]*\b$([regex]::Escape($requirementId))\b[^`r`n]*\|") {
        $problems.Add("No test-case row traces requirement: $requirementId")
    }
}

$testRows = @($plan -split "`r?`n" | Where-Object { $_ -match '^\s*\|\s*TC-[^|]+\|' })
if ($testRows.Count -lt $RequiredRequirementIds.Count) {
    $problems.Add("Expected at least $($RequiredRequirementIds.Count) test-case rows; found $($testRows.Count).")
}

if ($problems.Count -gt 0) {
    throw "PLAN_CHECK_RESULT: FAIL`n - $($problems -join "`n - ")"
}

Write-Host "PLAN_CHECK_RESULT: PASS requirements=$($RequiredRequirementIds.Count) cases=$($testRows.Count)"
