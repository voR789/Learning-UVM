# UB-02 Implementation Handoff

Updated: 2026-07-28

## Status

- UB-02 completed with guided evidence; UB-03 is reduced to a reading checkpoint
  because UI-G1 already demonstrated its virtual-interface/config_db objective.
- The module is a retrieval assessment, not a teach-first walkthrough.

## Scaffolding decision

- Top-level integration, runner, contract, rubric, and fixtures are supplied.
- The learner owns one lean package skeleton and a short reflection.
- No verification plan is assigned.
- TODOs name behavioral outcomes without prescribing exact statements.

## Verification boundary

- The known-good fixture must produce exactly three timed ticks.
- The known-bad fixture omits worker construction and must fail with
  `UB02_STRUCTURE`.
- XSim 2025.2 seed 1 passed the known-good fixture at 3 ns.
- The missing-worker fixture failed with `UB02_STRUCTURE` as intended.
- The learner starter failed compilation at the two constructor TODOs as
  intended.
- The learner submission passed XSim 2025.2 at seed 1. It registers both
  components, factory-creates the worker, advances three ticks over time, waits
  on worker state, and uses a deliberate null-handle fatal.
- Exact trace text and a hard-coded hierarchy path were removed from the learner
  completion contract because they were fixture details rather than UB-02's
  learning objective.
