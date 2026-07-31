# UA-04 implementation handoff

Updated: 2026-07-31

## Status

- UA-04 is the current substantive module after completed UA-03.
- UB-G1 already established independent specification modeling inside a
  scoreboard. UA-04 retains implementation because moving prediction into a
  separate producer and pairing two buffered TLM streams is new behavior.
- Learner work is limited to `ua04_predictor::write()`,
  `ua04_scoreboard::run_phase()`, and the reflection.

## First action

Read `resources/predictor-scoreboard-flow.md` and answer its prediction before
editing.

## Verification boundary

- Three observed commands must produce three expected results and three checks.
- Expected and actual results travel through distinct analysis FIFOs.
- The known-good fixture must pass with zero UVM errors/fatals.
- The corrupt-actual fixture must fail through `UA04_MISMATCH`.
- XSim 2025.2 seed 1 passed the independent reference flow with three emitted,
  predicted, and checked transactions and zero UVM errors/fatals.
- XSim 2025.2 seed 1 rejected the corrupt-actual fixture through
  `UA04_MISMATCH` for ID 1 (`0x99` expected versus `0x98` actual).
- The untouched learner starter compiles and intentionally fails through
  `UA04_COUNT` with three emitted, zero predicted, and zero checked.

## Ownership

Preserve learner ownership of `tb/ua04_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
