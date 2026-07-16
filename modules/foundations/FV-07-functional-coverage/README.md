# FV-07: Functional coverage

## Observable verification problem

A regression can pass every comparison while never exercising an important scenario. Functional coverage measures whether requirement-derived situations occurred; it does not decide whether the DUT behaved correctly.

This lab models completed ALU transactions and samples each one exactly once.

## Coverage specification

Create coverage for:

1. Every `op` encoding: five defined operations and three individual invalid selectors.
2. Operand classes for both `a` and `b`: zero, middle (`1` through `254`), and maximum (`255`).
3. Both values of `result_zero`.
4. A cross of each defined operation with `result_zero` asserted and deasserted. Ignore invalid operations in this cross.

Do not add bins merely to inflate a percentage. Each bin must map to the stated intent.

## Predict before coding

If every coverage bin is hit but expected values are never compared against DUT outputs, what kinds of bugs could still pass unnoticed?

## Your task

Complete `tb/coverage_lab.sv`:

1. Add the required coverpoints, bins, and cross.
2. Sample only inside `sample_transaction`, representing one completed transaction.
3. Run the starter stimulus and inspect the reported holes.
4. Add the smallest purposeful set of transactions that closes reachable coverage.
5. Keep `COVERAGE_RESULT` and `TEST_RESULT` distinct.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-07-functional-coverage"
.\run.ps1
```

The starter is expected to fail until coverage intent and closure stimulus are implemented.

Each run generates an XSim functional-coverage database and reports under `build`.
Use the text report for quick bin searches:

```text
build\coverage-report\functionalCoverageReport\xcrg_func_cov_report.txt
```

Open `build\coverage-report\functionalCoverageReport\dashboard.html` for the
interactive HTML report. Reports are generated even when incomplete coverage
causes the simulation to fail.
