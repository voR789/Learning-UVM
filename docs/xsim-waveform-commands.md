# XSim waveform commands

Use this sequence to compile a module and launch a fresh XSim GUI simulation for waveform inspection.

Replace every value enclosed in angle brackets, including the brackets, with the value for the current module. Close any XSim window using the module's `build` directory before recompiling.

## 1. Compile, elaborate, and run the automated test

Run this step whenever the DUT or testbench source changes:

```powershell
Set-Location '<module-directory>'

.\run.ps1 -Test '<testname>' -Seed <seed>
```

This recreates the module's `build` directory and produces the compiled simulation snapshot. It also runs the self-checking terminal simulation.

## 2. Launch a fresh GUI simulation

```powershell
Set-Location .\build

& '<vivado-root>\bin\xsim.bat' `
  -gui `
  -sv_seed <seed> `
  -testplusarg '"UVM_TESTNAME=<testname>"' `
  <snapshot-name>
```

Pass the snapshot name without the `.wdb` extension. A snapshot starts a new simulation at time zero; a `.wdb` file only opens a completed simulation for inspection.

After XSim opens, add the desired signals from **Scopes** and **Objects** to the Wave window, enter `run all` in the Tcl console, and use **Zoom Fit**.

## Placeholder reference

| Placeholder | Replace with |
|---|---|
| `<module-directory>` | Absolute path to the learning module containing `run.ps1` |
| `<testname>` | UVM test class selected through `UVM_TESTNAME` |
| `<seed>` | Integer seed used for both the automated and GUI runs |
| `<vivado-root>` | Vivado installation directory containing `bin\xsim.bat` |
| `<snapshot-name>` | Snapshot passed by the module's `run.ps1` to the shared runner |

If the source has not changed and the module's `build` directory still exists, step 1 may be skipped and the existing snapshot may be launched directly with step 2.
