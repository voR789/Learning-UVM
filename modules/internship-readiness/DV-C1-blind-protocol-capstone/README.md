# DV-C1 — blind TCS peripheral capstone

This is the transfer test: build a credible UVM environment for an interface you
have not practiced before, using the specification and RTL as your starting
point. The challenge is not UVM boilerplate. It is deciding what evidence proves
correct behavior when commands and responses decouple under backpressure.

Read [the TCS specification](spec/tcs-peripheral-spec.md). Do not inspect
`tests/faults` or use the reference fixture as a testbench design template; the
opaque fault is supplied to evaluate your checker, not reveal its construction.

## Prediction before coding

If two commands are accepted before either response transfers, and the first
response then stalls for three cycles, what observations must your environment
retain to decide whether the second response is correct?

Record the answer as the first decision in `plan/verification-plan.md`.

## Deliverables

You own the verification plan, all UVM implementation under `tb/`, and the
concise capstone report. Build a deterministic smoke test first, then stress
request/response backpressure, multiple outstanding commands, all operations,
and reset flushing. Coverage and checking must use passive pin-level evidence.

The supplied `tb/tb_top.sv` is only a clock/interface/configuration shell. It
expects a `dvc1_tb_pkg` and the test names listed in `tb/README.md`. Update the
learner source list near the top of `run.ps1` when you add files.

## Commands

From this directory:

```powershell
.\run.ps1 -Test tcs_smoke_test -Seed 1
```

Direct opaque-fault run:

```powershell
.\run.ps1 -Test tcs_stress_test -Seed 1 -Fault F1
```

Run the planned multi-test, multi-seed regression and merge its functional
coverage into one report:

```powershell
.\run-regression.ps1
```

The merged report is written under `coverage-merged/report/`.

The module-creation fixture can be checked independently with:

```powershell
.\run.ps1 -Reference -Seed 1
.\run.ps1 -Reference -Seed 1 -Fault F1
```

A learner pass requires `TEST_RESULT: PASS`, zero UVM errors/fatals, and a zero
process exit. The fault command must return nonzero for a behaviorally meaningful
diagnostic from your environment.

## Completion

Pass a deterministic smoke test, a documented multi-seed regression, reset
recovery, honest requirement coverage, and the opaque fault. Submit the concise
report; no duplicate evidence summary or generic reflection is required.
