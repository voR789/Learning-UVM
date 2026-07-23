[CmdletBinding()]
param([int]$Seed=1,[string]$PackagePath='',[string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop'
$moduleDirectory=$PSScriptRoot
if([string]::IsNullOrWhiteSpace($PackagePath)){$PackagePath=Join-Path $moduleDirectory 'tb\ui06_pkg.sv'}
$repositoryRoot=(Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
$runner=Join-Path $repositoryRoot 'scripts\run-xsim.ps1'
$sources=@((Resolve-Path -LiteralPath $PackagePath).Path,(Join-Path $moduleDirectory 'tb\tb_top.sv'))
& $runner -ModuleId 'UI-06' -ModuleDirectory $moduleDirectory -Sources $sources -Top 'tb_top' -Snapshot 'ui06_snapshot' -Test 'ui06_tlm_test' -Seed $Seed -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
