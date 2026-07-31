# UB-08 Implementation Handoff

Updated: 2026-07-29

## Status

- UB-08 was completed with guided evidence on 2026-07-29.
- The learner implemented `ub08_audit::write` and `report_phase`, then completed
  the reflection.
- XSim 2025.2 seed 1 passed the clean run with `checked=5 mismatches=0`; the
  injected-fault run emitted `UB08_MISMATCH` for ID 3 and preserved first-failure
  context in the final `UB08_SUMMARY`.

## Scope decision

- UI-G1 already established basic UVM reporting and pass/fail summaries.
- UB-08 requires a new behavioral invariant: a randomized mismatch must be
  reproducible from its seed and localizable from stable transaction context,
  while report phase retains aggregate evidence.
- Source generation, analysis wiring, fault injection, and transaction
  recording calls are supplied. The learner owns mismatch and summary policy.

## Prerequisite resource

- `resources/reproducible-diagnostics.md` teaches seed capture, transaction
  context, recording lifecycle, report phase, and one prediction before TODOs.
- XSim 2025.2 does not implement `$get_initial_random_seed`; the shared runner
  now accepts optional test plusargs, and UB-08 passes its actual `-sv_seed`
  value through `UB08_SEED`.

## Verification boundary

- The clean run must report five checks and zero mismatches.
- The fault run changes observation ID 3 and must emit `UB08_MISMATCH` with
  seed, ID, expected value, and observed value, then summarize one mismatch.
- A silent mismatch counter is rejected by the invalid fixture.
- XSim 2025.2 seed 1 passed the valid clean run, rejected the injected
  mismatch with complete `UB08_MISMATCH` context, and retained the report-phase
  summary.
- The silent-mismatch fixture was rejected because its fault run returned
  success without the required error report.
- The learner starter compiles and fails at its intentional `UB08_TODO`.
