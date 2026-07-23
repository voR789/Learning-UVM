[CmdletBinding()]
param(
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$runner = Join-Path $moduleDirectory 'run.ps1'
$valid = Join-Path $PSScriptRoot 'fixtures\valid_policy_lab.sv'
$invalid = Join-Path $PSScriptRoot 'fixtures\invalid_nonvirtual_lab.sv'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -SourcePath $valid -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -ne 0) {
    throw 'Valid polymorphism fixture did not pass.'
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner -SourcePath $invalid -Seed 1 -VivadoRoot $VivadoRoot
if ($LASTEXITCODE -eq 0) {
    throw 'Invalid non-virtual fixture passed unexpectedly.'
}

Write-Output 'FIXTURE_RESULT: PASS valid=passed invalid=failed_as_intended'
exit 0
