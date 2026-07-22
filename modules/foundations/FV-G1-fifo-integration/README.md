# FV-G1: Synchronous FIFO foundations integration gate

## Observable verification problem

A FIFO can appear correct under simple write-then-read traffic while violating ordering, capacity, reset, blocked-request, or simultaneous-operation requirements. Your task is to build evidence that distinguishes a correct FIFO from the intentionally buggy RTL supplied here.

This is an integration gate. You have already practiced its individual mechanisms, so the starter intentionally provides less architectural scaffolding.

For a resumed coaching session, read
[`implementation-handoff.md`](implementation-handoff.md) after the module
contract, specification, and progress record. It summarizes current work but
does not replace executable evidence.

## Authoritative DUT specification

Read [`spec/fifo-hardware-specification.md`](spec/fifo-hardware-specification.md)
before writing the verification plan. It is the authoritative source for
externally observable behavior and contains stable requirement IDs for
traceability.

The supplied configuration is `WIDTH=8`, `DEPTH=4`. Do not derive expected
behavior from the DUT implementation. If RTL behavior conflicts with the
specification, preserve the independent checker and report the RTL mismatch.

## Learner-owned deliverables

1. `plan/verification-plan.md`: trace the specification's requirement IDs to concrete checks before building the full environment.
2. `tb/fifo_tb.sv`: implement self-checking stimulus, passive observation, an independent reference model or scoreboard, assertions, coverage, timeout, and final status.
3. `reports/evidence-summary.md`: record tests, seeds, coverage holes, and concise defect evidence.
4. `reflection.md`: explain the architecture and debugging evidence in your own words.

You may reorganize learner-owned testbench code into additional files if you update `run.ps1` through a requested infrastructure change rather than silently bypassing the documented command.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-G1-fifo-integration"
.\run.ps1 -Seed 1
```

The untouched starter is expected to compile and fail because it performs no checks. A passing process exit alone is not completion evidence. The final environment must fail on scoreboard mismatches, assertion failures, timeouts, incomplete required coverage, or missing checks.

## Completion criteria

- Score at least 80 with no critical correctness failure.
- Detect and localize at least one seeded DUT defect without weakening the checker.
- Demonstrate a meaningful negative or fault case and retain a reproducing seed.
- Close all reachable required functional-coverage bins or justify an exclusion from the specification.
- Complete the evidence summary and reflection.

## Predict before coding

If a write request is observed while the reference model is full, what exact
information should the scoreboard use to predict acceptance, and why must DUT
`full` not be used as the prediction oracle?
