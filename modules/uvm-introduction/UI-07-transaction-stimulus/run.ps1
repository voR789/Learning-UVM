[CmdletBinding()]param([int]$Seed=1,[string]$PackagePath='',[string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop';$m=$PSScriptRoot
if([string]::IsNullOrWhiteSpace($PackagePath)){$PackagePath=Join-Path $m 'tb\ui07_pkg.sv'}
$r=(Resolve-Path -LiteralPath (Join-Path $m '..\..\..')).Path
& (Join-Path $r 'scripts\run-xsim.ps1') -ModuleId UI-07 -ModuleDirectory $m -Sources @((Resolve-Path $PackagePath).Path,(Join-Path $m 'tb\tb_top.sv')) -Top tb_top -Snapshot ui07_snapshot -Test ui07_test -Seed $Seed -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
