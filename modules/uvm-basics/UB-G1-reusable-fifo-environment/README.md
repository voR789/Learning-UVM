# UB-G1: Reusable UVM FIFO environment

## Why this gate is still implementation work

You already built a plain-SystemVerilog FIFO predictor/scoreboard in FV-G1 and
a complete UVM counter environment in UI-G1. Rewriting either exercise would be
low-value. This gate tests a new transfer decision: package those skills into a
reusable FIFO agent and let a sequence make bounded decisions from real driver
responses while correctness remains owned by passive observation and an
independent scoreboard.

The verification plan, DUT, interface, environment wiring, coverage model,
reporting policy, and routine UVM construction are supplied. Your work is
limited to the four behavioral boundaries where the transfer can be wrong:

1. response-driven scenario control;
2. pin-level request/response timing;
3. passive transaction publication;
4. independent FIFO prediction and checking.

## Learn first

Read [resources/status-driven-sequences.md](resources/status-driven-sequences.md)
before editing. It explains why a response used for scenario control is not a
scoreboard oracle.

## DUT contract

The local contract is [spec/fifo-spec.md](spec/fifo-spec.md). The FIFO is
single-clock, active-high synchronous reset, width 8, and depth 4. Acceptance
uses independent pre-edge model occupancy:

```text
write_accept = wr_en && occupancy_pre < DEPTH
read_accept  = rd_en && occupancy_pre > 0
```

There is no empty write-to-read bypass and no full read-to-write exception.

## Your work

Complete the four behavioral TODO regions in [tb/ub_g1_pkg.sv](tb/ub_g1_pkg.sv).
Do not rewrite the supplied plan, coverage bins, construction, connections, or
verdict formatting.

Run:

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-G1-reusable-fifo-environment"
.\run.ps1
```

The starter should fail at `UBG1_TODO`. A finished implementation must pass the
known-good FIFO and, using the same saved package, reject the faulty FIFO through
`UBG1_MISMATCH`.

## Constraints

- Only the driver writes FIFO inputs.
- The sequence may use responses to decide what request to issue next, but it
  may not declare DUT correctness.
- The scoreboard predicts only from passive monitor transactions and its own
  queue state.
- Every request receives exactly one response before the next adaptive decision.
- Do not hard-code the random seed, failing transaction, or DUT internal state.
- Expected time: 3 to 5 focused hours.

## Prediction

If a sequence stops filling because the driver response says `full==1`, why
must the passive scoreboard still independently decide whether `full` asserted
at the correct occupancy?

## Completion

Pass `run.ps1`, complete `reports/evidence-summary.md` and `reflection.md`, and
explain how response feedback, passive observation, and correctness checking
remain separate.
