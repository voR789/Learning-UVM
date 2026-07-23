# UI-05 Implementation Handoff

Updated: 2026-07-23

## Status

- UI-05 is current focus after guided UI-04 completion.
- Learner requested faster progression; this module combines agent, environment,
  configuration object, two tests, and a structural negative case.
- Learner owns `tb/ui05_pkg.sv` and `reflection.md`.

## Coaching start

1. Read the concise composition note and ask its boundary question.
2. Walk the clock-agent example and predict passive handles/topology.
3. Run active mode first and diagnose the first missing owned role.
4. Implement agent and environment build logic without modifying tests/checks.
5. Run both active and passive modes before reflection.

## Verification status

- Valid active test passed in XSim 2025.2 at seed 1 with driver, monitor,
  predictor, and scoreboard at the required paths.
- Valid passive test passed at seed 1 with monitor, predictor, and scoreboard
  and no driver.
- The always-driver fixture failed passive mode with one UVM fatal and explicit
  `passive_has_driver` evidence.
- The starter compiled and elaborated, then failed with only
  `uvm_test_top.env` present because required reusable roles were absent.
- Because each XSim UVM elaboration is slow on this host, configurations were
  verified individually rather than relying on one short outer timeout.

## Guardrails

- Direct config-handle propagation is intentional; config_db is deferred.
- Do not add sequencer, TLM, or coverage before their roadmap modules.
- Do not duplicate the environment class for passive mode.
- Do not allow a passive driver.
