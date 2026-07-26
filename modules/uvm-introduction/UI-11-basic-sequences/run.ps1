[CmdletBinding()]
param([int]$Seed=1,[string]$PackagePath='',[string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop'
$moduleDirectory=$PSScriptRoot
if([string]::IsNullOrWhiteSpace($PackagePath)){$PackagePath=Join-Path $moduleDirectory 'tb\ui11_pkg.sv'}
$repositoryRoot=(Resolve-Path -LiteralPath (Join-Path $moduleDirectory '..\..\..')).Path
& (Join-Path $repositoryRoot 'scripts\run-xsim.ps1') -ModuleId UI-11 -ModuleDirectory $moduleDirectory -Sources @((Resolve-Path -LiteralPath $PackagePath).Path,(Join-Path $moduleDirectory 'tb\tb_top.sv')) -Top tb_top -Snapshot ui11_snapshot -Test ui11_test -Seed $Seed -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
