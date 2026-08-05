# DV-02 — Plan and run a reproducible regression

## Why this matters

A regression is useful only if it tells you what ran, preserves failing conditions, and turns many red runs into a small number of engineering problems. Counting failures is clerical; grouping them by probable cause is DV work.

## Evidence-first novelty check

You have already run named UVM tests and repeated important seeds. DV-01 also showed that you can diagnose one isolated deterministic failure. The new transfer problem is **many-run triage**: keep the matrix running after failures, preserve the full run identity, compare signatures across tests and seeds, and form the smallest defensible set of root-cause buckets.

That judgment cannot be replaced by a reading checkpoint. This fixture deliberately contains passing runs, repeated symptoms, and more than one underlying defect class.

## Supplied environment

The environment models a small request processor with three tests:

| Test                     | Intent                                                      |
| ------------------------ | ----------------------------------------------------------- |
| `dv02_smoke_test`      | Deterministic low-risk operations; regression health anchor |
| `dv02_arithmetic_test` | Randomized arithmetic/data transformations                  |
| `dv02_completion_test` | Randomized request completion accounting                    |

The implementation is intentionally flawed. You are triaging, not repairing it. Do not inspect `tests/reference_pkg.sv` until assessment is complete.

## Your work

1. Review [regression-matrix.csv](plan/regression-matrix.csv). Keep a smoke anchor and at least three seeds for each randomized test; change seeds if you can justify better discriminating evidence.
2. Predict whether the number of failing runs will equal the number of root causes.
3. Run the complete matrix.
4. For every failure, identify the first decisive DUT/testbench signature—not the PowerShell wrapper error.
5. Re-run every distinct failure signature individually with the exact test and seed.
6. Complete only [triage-ledger.md](reports/triage-ledger.md). There is no separate reflection or generic evidence summary.

## Commands

Complete regression:

```powershell
./run-regression.ps1
```

The command is expected to return nonzero when any matrix row fails, but it must still execute every row and write `reports/latest-results.csv` plus per-run logs under `reports/run-logs/`.

Exact individual reproduction:

```powershell
./run.ps1 -Test dv02_arithmetic_test -Seed 17
```

Known-good fixture validation:

```powershell
./run.ps1 -Test dv02_arithmetic_test -Seed 17 -PackagePath ./tests/reference_pkg.sv
```

## Constraints

- Do not edit files under `tb/`, `tests/`, or either runner.
- Do not classify failures solely by report ID, test name, or pass/fail status.
- Do not stop after the first failure.
- Do not mark a failing run as expected-pass to make the regression green.
- A bucket needs a falsifiable root-cause hypothesis and a next experiment.

## Completion criteria

- Every matrix row has a recorded outcome and exact reproduction identity.
- Passing and failing runs are both retained.
- All distinct failure signatures are reproduced.
- The ledger uses the smallest evidence-supported number of buckets.
- Each bucket states shared evidence, contradicting evidence if any, and the next discriminating experiment.

## Prediction

If five runs fail with two different report IDs, what evidence would you need before claiming there are exactly two root causes?

- If five runs fail with two different report ID's, I would need to analyze what specific tests cause what ID (as the error may be testbench specific). Then, analyze what types of failures are being reported, to see if it's one root cause, or two distinct causes for it.
