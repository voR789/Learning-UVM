# UB-08: Make failures reproducible and reports useful

## Why this matters

“Mismatch” is not enough to debug a regression. A useful failure identifies
the seed and the transaction that failed, while the final summary tells you
whether the run completed cleanly and how much work was checked.

## Learn first

Read [resources/reproducible-diagnostics.md](resources/reproducible-diagnostics.md)
before editing. It introduces seed capture, report-phase summaries, and the
difference between transaction recording and report text.

## Observable contract

The supplied source publishes five observations:

- a clean test makes every `observed` value equal `expected`;
- a fault test changes exactly one observed value;
- each observation has a unique ID and a transaction-recording lifecycle;
- the audit subscriber checks every observation;
- a mismatch report includes seed, ID, expected value, and observed value;
- report phase summarizes seed, checked count, mismatch count, and the first
  failure context.

Exact whitespace is not graded.

## Your work

Complete the behavioral TODOs in [tb/ub08_pkg.sv](tb/ub08_pkg.sv). The supplied
source, tests, analysis connection, transaction fields, and recording calls are
already complete. You own mismatch diagnostics and the final audit summary.

Run both the clean and fault-detection checks:

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-08-reproducible-useful-reports"
.\run.ps1
```

The overall command passes only when the clean run succeeds and the injected
fault fails for `UB08_MISMATCH`.

## Constraints

- Do not fatal on the first mismatch; preserve final report-phase evidence.
- Do not hard-code the simulator seed or failing transaction values.
- Use the received transaction's live fields in diagnostics.
- Expected time: about 75 minutes.

## Prediction

If two failing runs report the same transaction values but omit their seeds,
what information is missing when the stimulus was randomized?

## Completion

Pass `run.ps1`, complete [reflection.md](reflection.md), and explain how the
reported evidence reproduces and localizes the seeded fault.
