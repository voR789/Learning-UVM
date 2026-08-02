[CmdletBinding()]
param([string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado')

$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot 'run.ps1'
$rows = @(
    @{ Test = 'ua07_smoke_test'; Seed = 1; Intent = 'deterministic smoke' },
    @{ Test = 'ua07_stress_test'; Seed = 1; Intent = 'randomized stress' },
    @{ Test = 'ua07_stress_test'; Seed = 17; Intent = 'alternate randomized stress' }
)

foreach ($row in $rows) {
    Write-Host "[UA-07 REGRESSION] test=$($row.Test) seed=$($row.Seed) intent=$($row.Intent)"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner `
        -Test $row.Test -Seed $row.Seed -VivadoRoot $VivadoRoot
    if ($LASTEXITCODE -ne 0) {
        Write-Error "[UA-07 REGRESSION] FAIL test=$($row.Test) seed=$($row.Seed)"
        exit 1
    }
}

Write-Output 'REGRESSION_RESULT: PASS rows=3'
exit 0
