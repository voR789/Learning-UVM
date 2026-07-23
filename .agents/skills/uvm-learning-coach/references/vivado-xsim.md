# Vivado 2025.2 and XSim Reference

## Target

- AMD Vivado/XSim 2025.2.
- SystemVerilog sources use `.sv`.
- Use the precompiled UVM 1.2 library supplied with Vivado.
- Use Windows PowerShell for learner-facing entry points.

## Standalone flow shape

A module runner should stop on the first failed stage:

1. Locate Vivado 2025.2 tools or require an initialized Vivado environment.
2. Compile SystemVerilog with `xvlog`, including `-sv` and the `uvm` library for UVM modules.
3. Elaborate with `xelab`, including the `uvm` library and an explicit snapshot name.
4. Run the snapshot with `xsim`, passing the test and seed.
5. Enforce UVM, assertion, timeout, and scoreboard failure status.
6. Return nonzero on any failed stage.

Representative command shape only; verify exact arguments in the shared runner:

```powershell
xvlog -sv -L uvm <ordered source files>
xelab -L uvm <top> -s <snapshot>
xsim <snapshot> -R -testplusarg UVM_TESTNAME=<test> -sv_seed <seed>
```

Do not copy this shape into every module once a shared runner exists. Centralize compile order and plusarg handling.

## Compatibility discipline

- XSim supports a subset of SystemVerilog. Probe questionable constructs with the smallest compilable example.
- Separate an XSim limitation from an incorrect language assumption in diagnostics.
- XSim 2025.2 has exhibited an unrecoverable kernel failure when an unselected
  ternary branch contains a method call through a null class/component handle.
  Do not rely on short-circuit branch evaluation for maybe-null dereferences;
  assign diagnostics or derived values with an explicit `if/else` null guard.
  The UI-05 passive-agent run on 2026-07-23 reproduced the crash and passed
  after replacing the ternary with guarded control flow.
- Do not rewrite methodology merely because initial invocation syntax failed.
- Record a working command and Vivado version after infrastructure fixes.
- Re-run both a known pass and known fail after runner changes.

## Reproducibility record

For every run, retain or print:

- Module ID.
- UVM test name when applicable.
- Seed.
- Vivado/XSim version when practical.
- Snapshot or top name.
- Final result.
- UVM warning/error/fatal counts.

Do not commit logs, snapshots, wave databases, or simulator work directories.
