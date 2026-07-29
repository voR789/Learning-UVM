# UB-04 Implementation Handoff

Updated: 2026-07-28

## Status

- UB-04 completed with independent evidence; UB-05 is the next focus.

## Scaffolding

- Tests, mode configuration, topology checks, and runner are supplied.
- The learner owns only component mechanics and agent build/connect behavior.
- No verification plan or exact trace-string requirement is assigned.

## Verification boundary

- Active mode must create and connect monitor, driver, and sequencer.
- Passive mode must retain only the monitor.
- Known-good and contradictory-passive fixtures require XSim validation.
- XSim 2025.2 seed 1 passed the valid active topology with its request port
  connected and the valid passive monitor-only topology.
- The contradictory passive fixture failed with `UB04_PASSIVE_TOPOLOGY`.
- XSim's precompiled UVM port does not expose `is_connected()` here; the
  Codex-owned checker uses `size() > 0` to observe the connection.
- The learner starter fails compilation at its intentional constructor TODOs.
- Learner source passed active and passive XSim 2025.2 tests at seed 1 with
  zero UVM errors/fatals.
- The learner corrected an initially unconditional sequencer construction after
  one diagnostic question and completed the reflection accurately.
