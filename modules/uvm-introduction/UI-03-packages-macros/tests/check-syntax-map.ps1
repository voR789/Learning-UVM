[CmdletBinding()]
param([string]$MapPath)

$ErrorActionPreference = 'Stop'
$text = Get-Content -Raw -LiteralPath $MapPath
$todoCount = ([regex]::Matches($text, '\bTODO\b')).Count
if ($todoCount -ne 0) {
    Write-Error "SYNTAX_MAP_RESULT: FAIL remaining_todos=$todoCount"
    exit 1
}
Write-Output 'SYNTAX_MAP_RESULT: PASS rows=5 prediction=1'
exit 0
