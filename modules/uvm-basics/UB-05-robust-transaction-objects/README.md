# UB-05: Design robust transaction objects

## Why this matters

A transaction is the shared meaning passed among sequences, drivers, monitors,
scoreboards, logs, and coverage. If its constraints, copy behavior, comparison,
or text representation disagree about which fields matter, failures become
silent or misleading.

## Learn first

Read [resources/transaction-object-semantics.md](resources/transaction-object-semantics.md)
before editing the package. It introduces the field automation macros and the
behavior exercised by the supplied test.

## Observable contract

`ub05_packet` represents one simple request:

- `address` is between `8'h10` and `8'h1f`, inclusive;
- `data` may be any 16-bit value for reads, but cannot be zero for writes;
- `write` selects read or write;
- copy and compare include all three fields;
- `convert2string()` reports all three live values in a concise string.

Exact whitespace or label wording in the string is not graded.

## Reading checkpoint

Read the resource, answer the prediction mentally, and run the supplied example.
There is no required implementation or reflection: your prior work already
demonstrates registration, object construction, and the choice to automate a
subset of fields. The unfinished [tb/ub05_pkg.sv](tb/ub05_pkg.sv) is preserved
only as optional extra practice.

Run:

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-05-robust-transaction-objects"
.\run.ps1
```

The supplied example randomizes a packet, copies and compares it, then mutates
the copy and requires comparison to detect the change.

## Constraints

- Keep all three fields meaningful.
- Use UVM field automation for copy/compare in this exercise.
- Do not hard-code the randomized result or diagnostic string.
- Expected time: about 15 minutes.

## Prediction

If `data` is omitted from the transaction's field automation, what happens when
only the copied packet's `data` value changes?

## Completion

The checkpoint is complete when the supplied example passes and the omitted-
field fixture fails for the comparison invariant.
