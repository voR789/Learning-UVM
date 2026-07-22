[CmdletBinding()]
param()

$checker = Join-Path $PSScriptRoot 'check-map.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid-map.md'
$invalid = Join-Path $PSScriptRoot 'fixtures\invalid-map.md'

& $checker -MappingPath $valid
if ($LASTEXITCODE -ne 0) {
    throw 'Valid mapping fixture did not pass.'
}

& $checker -MappingPath $invalid 2>$null
if ($LASTEXITCODE -eq 0) {
    throw 'Invalid mapping fixture did not fail.'
}

Write-Host 'CHECKER_SELF_TEST: PASS'
exit 0
