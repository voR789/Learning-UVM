# UB-05 Implementation Handoff

Updated: 2026-07-28

## Status

- UB-05 is the current focus and remains `not_started`.
- The learner package is intentionally incomplete.

## Scaffolding

- A prerequisite resource teaches field automation and aligned transaction
  semantics with an unrelated worked example.
- The checker, runner, and fault fixture are supplied.
- The learner owns one transaction class and a short reflection.
- No verification plan or exact diagnostic-string format is required.

## Verification boundary

- Legal randomization, copy equivalence, mutation detection, and a nonempty
  live-state string are required.
- The negative fixture omits `data` from field automation and must fail when
  that mutation is ignored.
- XSim 2025.2 seed 1 passed the valid fixture and rejected the omitted-`data`
  field fixture with `UB05_COMPARE`.
- The starter reaches elaboration and fails at its intentional missing
  registration/type factory TODO.
