# FV-00: XSim and UVM command-line smoke test

## Why this matters

Verification regressions must run unattended. This module proves that Vivado 2025.2 can compile, elaborate, and execute a UVM 1.2 test from PowerShell without opening the Vivado GUI.

## DUT behavior

The DUT is a four-bit synchronous counter with active-low synchronous reset. On each rising clock edge:

- Reset sets the count to zero.
- Otherwise, an asserted enable increments the count by one.
- A deasserted enable holds the current count.

## Your task

Run the passing smoke test:

```powershell
.\run.ps1
```

Then verify the runner itself:

```powershell
.\tests\verify-runner.ps1
```

Read the console output and the generated files under `build/`. Identify which stage produced each log.

## Useful variations

```powershell
.\run.ps1 -Test smoke_pass_test -Seed 12345
.\run.ps1 -Test smoke_expected_fail_test -Seed 12345
```

The second command is supposed to return a nonzero exit code because the test emits a deliberate `UVM_ERROR`.

## Completion criteria

- `smoke_pass_test` returns zero and prints `TEST_RESULT: PASS`.
- `smoke_expected_fail_test` returns nonzero.
- You can explain what `xvlog`, `xelab`, and `xsim` each do.
- You complete `reflection.md` in your own words.

## Prediction

Before running the module: if XSim returns process exit code zero but the UVM report contains one `UVM_ERROR`, should the PowerShell runner report success or failure? Explain why.

