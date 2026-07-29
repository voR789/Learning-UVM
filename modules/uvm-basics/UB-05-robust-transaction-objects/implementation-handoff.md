# UB-05 Implementation Handoff

Updated: 2026-07-28

## Status

- UB-05 is complete as a read-only checkpoint.
- The learner package remains untouched as optional practice.

## Scaffolding

- A prerequisite resource teaches field automation and aligned transaction
  semantics with an unrelated worked example.
- Added an unrelated `$sformatf`/`convert2string()` syntax example after the
  learner correctly identified that the original resource omitted it.
- The checker, runner, and fault fixture are supplied.
- No learner-authored implementation or reflection is required.
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
- Conversion decision: the learner already understood selective field
  registration, and completing another transaction macro exercise would add
  clerical repetition rather than a new behavioral decision.
