[CmdletBinding()]
param(
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$checkpoint = Join-Path $PSScriptRoot 'tests\verify-checkpoint.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $checkpoint -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
