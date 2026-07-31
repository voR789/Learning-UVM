# UA-01 implementation handoff

Updated: 2026-07-30

## Status

- UA-01 was converted to a completed read-only checkpoint by the repository's
  evidence-first novelty rule.
- UI-05 already implements a configuration object and one unchanged
  active/passive environment.
- UB-04 independently rebuilds the active/passive agent topology.
- UB-G1 transfers the boundary to a reusable FIFO environment with real
  stimulus, observation, checking, coverage, and fault detection.
- Reauthoring the architecture would add no new behavioral invariant.

## Executable boundary

- `run.ps1` replays the UI-05 active and passive valid fixtures.
- The same run rejects an always-driver passive topology.
- XSim 2025.2 seed 1 passed both valid structures and rejected the
  always-driver passive topology on 2026-07-30.

## Learner entry point

Read `resources/reusable-block-boundaries.md`. The prediction asks which
artifact should vary when the same agent/environment classes need different
active/passive modes.

An optional detailed `resources/config-db-worked-example.md` was added at the
learner's request. It traces interface handles and nested agent configurations
from HDL top through test and environment into two active agents and one passive
agent. It is reference material, not a new completion requirement.

## Next

UA-02 is the next substantive module. Factory type and instance overrides are
new behavior; they are not waived by this checkpoint.
