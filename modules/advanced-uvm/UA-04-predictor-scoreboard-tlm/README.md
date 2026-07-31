# UA-04: Predictor-to-scoreboard TLM flow

## Why this is implementation work

In UB-G1, your scoreboard owned both the reference model and the comparison.
That was correct for a compact block environment. This module introduces a new
reusable boundary:

```text
observed command -> predictor -> expected FIFO -> scoreboard
observed result  ----------------> actual FIFO --> scoreboard
```

The predictor owns specification-based transformation. The scoreboard owns
pairing and comparison. Separate analysis FIFOs absorb arrival-time differences
without turning the predictor into a driver or sequence controller.

## Learn first

Read [resources/predictor-scoreboard-flow.md](resources/predictor-scoreboard-flow.md)
and answer its prediction before editing.

## Supplied environment

The source publishes three command observations and three independently formed
actual results. All transaction types, source behavior, environment construction,
TLM connections, test control, and result accounting are supplied.

## Your work

Complete two behavioral regions in `tb/ua04_pkg.sv`:

1. In `ua04_predictor::write()`, create and publish exactly one expected result
   for each observed command using the documented ADD/XOR specification.
2. In `ua04_scoreboard::run_phase()`, consume one expected and one actual result
   from the separate FIFOs, then compare identity and value.

Do not move prediction into the source or scoreboard. Do not connect the
predictor to the sequencer. The source and environment are already complete.

Run the learner test:

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-04-predictor-scoreboard-tlm"
.\run.ps1
```

## Fault check

Run the corrupt-actual fixture directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua04_corrupt_actual_test
```

Expected result: nonzero exit and `UA04_MISMATCH`.

Run all fixtures with:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If the actual result reaches its FIFO before the predictor publishes the
matching expected result, does the scoreboard necessarily lose the comparison?
Explain what the two FIFOs change.

## Completion

The learner run passes at seed 1, the corrupt-actual fixture fails through
`UA04_MISMATCH`, counts show three emitted/predicted/checked transactions, and
the reflection explains the component boundaries.
