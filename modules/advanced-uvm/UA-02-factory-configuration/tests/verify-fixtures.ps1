[CmdletBinding()]
param(
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$fixtureRunner = Join-Path $PSScriptRoot 'run-fixture.ps1'

foreach ($test in @('ua02_valid_type_test', 'ua02_valid_instance_test')) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
        -Test $test -VivadoRoot $VivadoRoot
    if ($LASTEXITCODE -ne 0) {
        throw "UA-02 valid fixture failed: $test"
    }
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureRunner `
    -Test 'ua02_wrong_path_test' -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'UA-02 wrong-path fixture passed unexpectedly.'
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
    (Join-Path $moduleDirectory 'run.ps1') -Test 'ua02_type_override_test' `
    -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'UA-02 learner starter passed without installing its override.'
}

Write-Output 'FIXTURE_RESULT: PASS type=passed instance=passed wrong_path=failed starter=failed'
exit 0
