# UA-03: Extend and encapsulate transaction models

## Why this is implementation work

UB-05 already established normal transaction fields, copy, compare, and useful
printing. This module adds a new transfer decision: a derived transaction must
preserve its own state *and* the base transaction's state. A copy that handles
only one layer silently creates a transaction that no longer represents the
request it was cloned from.

## Learn first

Read [resources/extended-transaction-models.md](resources/extended-transaction-models.md).
It uses a separate packet example. Answer its prediction before editing code.

## Supplied model

`ua03_cmd` owns an aligned address and command kind. `ua03_burst_cmd` extends
it with a burst length and byte stride. Their state is protected; callers use
the supplied configuration and query methods instead of reaching into fields.

The supplied test configures a valid burst, copies it, checks equivalence, then
mutates the copy to prove compare detects the change.

## Your work

Complete the TODO regions in `tb/ua03_pkg.sv`:

1. Make the derived transaction validate both the inherited command contract
   and its burst contract.
2. Make derived copy and compare preserve/check both base and burst state.

Do not expose the fields or change the supplied test flow. The point is the
base-plus-extension invariant, not a new testbench architecture.

Run the learner test:

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-03-extend-encapsulate-transaction-models"
.\run.ps1
```

## Fault check

Run the seeded extension-loss fixture directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua03_extension_loss_test
```

Expected result: nonzero exit and `UA03_COPY`. The fixture substitutes a
transaction implementation that drops its subtype state while copying.

Run all fixtures with:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If a derived `do_copy()` copies only `burst_len` and `byte_stride`, but never
delegates to the base transaction, which part of the cloned request can become
wrong even though the burst settings look correct?

## Completion

The learner test passes at seed 1, the extension-loss fixture fails through
`UA03_COPY`, and the reflection explains extension, encapsulation, and the
copy/compare invariant.
