# UB-02: Rebuild a minimal UVM test from memory

## Why this matters

You have already used these mechanics inside larger testbenches. This assessment
checks whether the basic UVM lifecycle is now retrievable without a
fill-in-the-blank solution.

## Observable contract

There is no RTL DUT. A worker component represents concurrent verification work.

- The test must factory-create one worker.
- The worker must produce exactly three ticks during `run_phase`.
- The test must keep simulation alive until the third tick, check the result,
  print its observed tick count and report `TEST_RESULT: PASS`.
- Any missing worker, wrong tick count, UVM error, fatal, or
  timeout must fail.

## Your work

Implement the behavioral TODOs in [tb/ub02_pkg.sv](tb/ub02_pkg.sv). The class
names, state, and method boundaries are supplied; their UVM mechanics and
behavior are yours.

After the test passes, answer [reflection.md](reflection.md) briefly. There is no
verification-plan assignment.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-02-minimal-uvm-rebuild"
.\run.ps1
```

The starter is expected to fail. A completed solution reports its observed state
and pass marker at seed 1.

## Constraints

- Use factory registration and factory creation.
- Create the worker in the test's `build_phase`.
- Do not hard-code a pass result without checking live component state.
- The test, not the worker, owns end-of-test objection policy.
- Expected time: about 75 minutes.

## Prediction before coding

If the worker drops an objection but the test never raised one, what guarantees
that the test remains alive long enough to observe all three ticks?
