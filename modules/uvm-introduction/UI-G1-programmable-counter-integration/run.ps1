[CmdletBinding()]
param([int]$Seed=1,[string]$PackagePath='',[string]$DutPath='',[string]$VivadoRoot='C:\AMDDesignTools\2025.2\Vivado')
$ErrorActionPreference='Stop';$m=$PSScriptRoot
if([string]::IsNullOrWhiteSpace($PackagePath)){$PackagePath=Join-Path $m 'tb\ui_g1_pkg.sv'}
if([string]::IsNullOrWhiteSpace($DutPath)){$DutPath=Join-Path $m 'dut\counter.sv'}
$r=(Resolve-Path -LiteralPath (Join-Path $m '..\..\..')).Path
& (Join-Path $r 'scripts\run-xsim.ps1') -ModuleId UI-G1 -ModuleDirectory $m -Sources @((Join-Path $m 'tb\counter_if.sv'),(Resolve-Path $DutPath).Path,(Resolve-Path $PackagePath).Path,(Join-Path $m 'tb\tb_top.sv')) -Top tb_top -Snapshot ui_g1_snapshot -Test counter_test -Seed $Seed -FunctionalCoverageReport -VivadoRoot $VivadoRoot
exit $LASTEXITCODE
