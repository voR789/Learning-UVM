# UI-05 Implementation Handoff

Updated: 2026-07-23

## Status

- UI-05 completed with guided evidence on 2026-07-23; UI-06 is now current focus.
- Learner requested faster progression; this module combines agent, environment,
  configuration object, two tests, and a structural negative case.
- Learner owns `tb/ui05_pkg.sv` and `reflection.md`.

## Completion evidence

- Final learner active and passive tests passed in XSim 2025.2 at seed 1 with
  zero UVM errors/fatals and the required distinct topologies.
- The same environment class served both configurations; monitor remained
  present and driver existed only in active mode.
- Reflection explained ownership, configuration propagation, passive safety,
  reuse, and the transaction connections deferred to UI-06.
- Progress recorded as `guided`, score 95.

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
- A learner passive run exposed an XSim 2025.2 kernel crash when a ternary
  expression's unselected branch called `get_full_name()` through the null
  passive-driver handle. Replacing that expression with an explicit null guard
  and temporary string restored a passing passive run with `driver=<absent>`
  and zero UVM errors/fatals on 2026-07-23.
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
