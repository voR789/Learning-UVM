# UB-08 Implementation Handoff

Updated: 2026-07-29

## Status

- UB-08 is ready and is the current focus.
- The learner package intentionally fails at `UB08_TODO`.
- This handoff was refreshed for a new coaching task; the learner has not
  started the implementation or reflection.
- First action: read `resources/reproducible-diagnostics.md`, answer its
  prediction, then implement `ub08_audit::write` and `report_phase`.

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
