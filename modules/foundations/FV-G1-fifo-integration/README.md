# FV-G1: Synchronous FIFO foundations integration gate

## Observable verification problem

A FIFO can appear correct under simple write-then-read traffic while violating ordering, capacity, reset, blocked-request, or simultaneous-operation requirements. Your task is to build evidence that distinguishes a correct FIFO from the intentionally buggy RTL supplied here.

This is an integration gate. You have already practiced its individual mechanisms, so the starter intentionally provides less architectural scaffolding.

## DUT contract

The DUT is a rising-edge synchronous FIFO with `WIDTH=8` and `DEPTH=4` in the supplied configuration.

- `rst` is active high and synchronous. On a reset edge, occupancy becomes zero, `empty` is asserted, `full` is deasserted, pointers are reset, and `rdata` becomes zero.
- A write is accepted on a rising edge when `wr_en && !full`. The accepted `wdata` is appended to the FIFO.
- A read is accepted on a rising edge when `rd_en && !empty`. After that edge, `rdata` presents the oldest queued item.
- Status used to decide acceptance is the status immediately before the active edge.
- When a read and write are both accepted on the same edge, ordering is preserved and occupancy is unchanged.
- A write attempted while full and a read attempted while empty are rejected without changing FIFO contents, pointers, occupancy, or `rdata`.
- `count` reports occupancy from zero through `DEPTH`; `empty` is equivalent to `count == 0`; `full` is equivalent to `count == DEPTH`.

Do not derive expected behavior from the DUT implementation. Treat this contract as authoritative.

## Learner-owned deliverables

1. `plan/verification-plan.md`: trace requirements to concrete checks before building the full environment.
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

If the driver sends a write request while the FIFO is full, which object should decide whether the reference model appends that item: the driver request or the passively observed acceptance condition?
