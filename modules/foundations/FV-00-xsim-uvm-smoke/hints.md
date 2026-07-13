# FV-00 Hints

## Level 1: Diagnostic question

Which of the three tool stages first creates a runnable simulation snapshot?

## Level 2: Concept

Compilation checks source units; elaboration resolves hierarchy and creates the snapshot; simulation executes it.

## Level 3: Location

Inspect `scripts/run-xsim.ps1` and the three logs under `build/`.

## Level 4: Pseudocode

```text
compile ordered sources
if compile failed: stop
elaborate top into snapshot
if elaboration failed: stop
run snapshot with test and seed
inspect UVM summary and explicit pass marker
```

## Level 5: Minimal repair direction

Confirm `VivadoRoot` points to the directory containing `bin\xvlog.bat`, `bin\xelab.bat`, and `bin\xsim.bat`.

## Level 6: Reference answer

The verified default is `C:\AMDDesignTools\2025.2\Vivado`. Run `tests\verify-runner.ps1` to execute both the pass and expected-failure cases.

