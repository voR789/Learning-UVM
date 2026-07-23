[CmdletBinding()]
param(
    [int]$Seed = 1,
    [string]$SourcePath = '',
    [string]$VivadoRoot = 'C:\AMDDesignTools\2025.2\Vivado'
)

$ErrorActionPreference = 'Stop'
$moduleDirectory = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    $SourcePath = Join-Path $moduleDirectory 'tb\policy_lab.sv'
}
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner = Join-Path $repositoryRoot 'scripts\run-xsim.ps1'

& $runner `
    -ModuleId 'UI-02' `
    -ModuleDirectory $moduleDirectory `
    -Sources @((Resolve-Path -LiteralPath $SourcePath).Path) `
    -Top 'policy_lab' `
    -Snapshot 'ui02_snapshot' `
    -Test 'inheritance_polymorphism_test' `
    -Seed $Seed `
    -VivadoRoot $VivadoRoot

exit $LASTEXITCODE
