[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleId,

    [Parameter(Mandatory = $true)]
    [string]$ModuleDirectory,

    [Parameter(Mandatory = $true)]
    [string[]]$Sources,

    [Parameter(Mandatory = $true)]
    [string]$Top,

    [Parameter(Mandatory = $true)]
    [string]$Snapshot,

    [Parameter(Mandatory = $true)]
    [string]$Test,

    [int]$Seed = 1,

    [string]$VivadoRoot = $(
        if ($env:VIVADO_ROOT) {
            $env:VIVADO_ROOT
        } else {
            'C:\AMDDesignTools\2025.2\Vivado'
        }
    )
)

$ErrorActionPreference = 'Stop'

function Invoke-XSimStage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Executable,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$LogPath
    )

    Write-Host "[$ModuleId] $Name"
    & $Executable @Arguments 2>&1 | Tee-Object -FilePath $LogPath
    $stageExitCode = $LASTEXITCODE

    if ($stageExitCode -ne 0) {
        throw "$Name failed with exit code $stageExitCode. See $LogPath"
    }
}

try {
    $modulePath = (Resolve-Path -LiteralPath $ModuleDirectory).Path
    $vivadoPath = (Resolve-Path -LiteralPath $VivadoRoot).Path

    $xvlog = Join-Path $vivadoPath 'bin\xvlog.bat'
    $xelab = Join-Path $vivadoPath 'bin\xelab.bat'
    $xsim = Join-Path $vivadoPath 'bin\xsim.bat'

    foreach ($tool in @($xvlog, $xelab, $xsim)) {
        if (-not (Test-Path -LiteralPath $tool -PathType Leaf)) {
            throw "Required Vivado tool not found: $tool"
        }
    }

    $resolvedSources = foreach ($source in $Sources) {
        (Resolve-Path -LiteralPath $source).Path
    }

    $buildDirectory = Join-Path $modulePath 'build'
    if (Test-Path -LiteralPath $buildDirectory) {
        $resolvedBuild = (Resolve-Path -LiteralPath $buildDirectory).Path
        $expectedBuild = [System.IO.Path]::GetFullPath($buildDirectory)
        if ($resolvedBuild -ne $expectedBuild -or -not $resolvedBuild.StartsWith($modulePath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Unsafe build cleanup target: $resolvedBuild"
        }
        Remove-Item -LiteralPath $resolvedBuild -Recurse -Force
    }
    New-Item -ItemType Directory -Path $buildDirectory | Out-Null

    Write-Host "[$ModuleId] Vivado root: $vivadoPath"
    Write-Host "[$ModuleId] Test: $Test"
    Write-Host "[$ModuleId] Seed: $Seed"
    Write-Host "[$ModuleId] Build: $buildDirectory"

    Push-Location $buildDirectory
    try {
        $compileLog = Join-Path $buildDirectory 'compile.log'
        $elaborateLog = Join-Path $buildDirectory 'elaborate.log'
        $simulationLog = Join-Path $buildDirectory 'simulation.log'

        $compileArguments = @('-sv', '-L', 'uvm') + $resolvedSources
        Invoke-XSimStage -Name 'Compile' -Executable $xvlog -Arguments $compileArguments -LogPath $compileLog

        # XSim rejects mixed timescale declarations when the precompiled UVM
        # package has none, so establish one global elaboration timescale.
        $elaborateArguments = @(
            '-L', 'uvm',
            '-debug', 'typical',
            '-timescale', '1ns/1ps',
            $Top,
            '-s', $Snapshot
        )
        Invoke-XSimStage -Name 'Elaborate' -Executable $xelab -Arguments $elaborateArguments -LogPath $elaborateLog

        # Preserve literal quotes around NAME=value. The Windows XSim wrapper
        # otherwise splits the value and reports "Expected a switch".
        $simulationArguments = @(
            $Snapshot,
            '-R',
            '-sv_seed', $Seed.ToString(),
            '-testplusarg', "`"UVM_TESTNAME=$Test`""
        )
        Invoke-XSimStage -Name 'Simulate' -Executable $xsim -Arguments $simulationArguments -LogPath $simulationLog

        $simulationText = Get-Content -LiteralPath $simulationLog -Raw
        $hasUvmErrors = $simulationText -match '(?m)^\s*UVM_(ERROR|FATAL)\s*:\s*[1-9][0-9]*\s*$'
        $hasPassMarker = $simulationText -match '(?m)^TEST_RESULT:\s*PASS\s*$'

        if ($hasUvmErrors) {
            throw "Simulation completed with UVM errors or fatals. See $simulationLog"
        }
        if (-not $hasPassMarker) {
            throw "Simulation did not emit TEST_RESULT: PASS. See $simulationLog"
        }

        Write-Host "[$ModuleId] PASS: test=$Test seed=$Seed"
    } finally {
        Pop-Location
    }
} catch {
    Write-Error "[$ModuleId] FAIL: $($_.Exception.Message)"
    exit 1
}

exit 0
