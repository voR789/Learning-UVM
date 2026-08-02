# UA-07: Maintainable test hierarchy and regression set

## Why this is implementation work

You have already built tests, raised objections, started sequences, checked
responses, and reproduced seeded runs. Repeating those mechanics in several
new tests would add little value.

The new invariant is architectural: every test in a family must inherit the
same execution and completion contract. A derived test may select a different
scenario, but it must not duplicate or bypass objection handling, accounting,
or the final pass decision.

Regression taxonomy and the PowerShell matrix are supplied as a reading and
execution checkpoint. You do not need to re-author runner boilerplate.

## Learn first

Read
[resources/base-tests-and-regressions.md](resources/base-tests-and-regressions.md)
and answer its prediction before editing.

## Supplied verification model

There is no RTL DUT in this focused module. The supplied environment contains
one sequencer and one response-producing driver. Two supplied scenarios check
their own responses:

- smoke sends two deterministic items;
- stress sends six seed-dependent randomized items.

The supplied derived tests differ only in which scenario their factory hook
creates. The runner selects a test through `UVM_TESTNAME` and records its seed.

## Your work

Complete the single TODO in `tb/ua07_tests_pkg.sv`:

- implement the shared `ua07_base_test::run_phase()` lifecycle;
- obtain the scenario through the existing virtual selection hook;
- reject a missing scenario before dereferencing it;
- own the objection for the complete scenario lifecycle;
- require the scenario and driver counts to agree and be nonzero;
- record successful completion so the inherited phase check can accept the
  test.

Do not override `run_phase()` in either derived test. Do not move response
checking into the test.

## Run one test

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-07-maintainable-test-hierarchy"
.\run.ps1 -Test ua07_smoke_test -Seed 1
```

## Run the regression

```powershell
.\run-regression.ps1
```

The supplied matrix runs smoke once and stress at more than one seed. A failure
is reproduced by rerunning the exact test and seed printed by the runner.

## Direct fault command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua07_bypass_common_run_test
```

Expected result: nonzero exit and `UA07_CONTRACT`.

Run all fixture checks with:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If a derived test overrides `run_phase()` and runs a valid scenario but never
executes the base test's shared lifecycle, should the scenario's correct
responses be sufficient for the test to pass?

## Completion

The documented regression passes, the direct fault fails through
`UA07_CONTRACT`, and the reflection explains ownership, selection, termination,
and exact test/seed reproduction.
