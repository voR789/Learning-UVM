# UB-01 Implementation Handoff

Updated: 2026-07-28

## Status

- Created after UI-G1 passed the Introduction integration gate with guided evidence.
- UB-01 was converted to a completed read-only checkpoint after the learner
  correctly explained its core ownership decision.
- The module is deliberately short and conceptual before the UB-02 rebuild-from-memory assessment.

## Reduced scaffolding

- The executable UVM example and process setup are Codex-owned.
- The learner receives a lean decision skeleton rather than a guided,
  fill-in-the-code implementation.
- Verification-plan work is omitted because planning is not the objective.
- TODOs ask for ownership and reuse decisions without prescribing exact answers.

## Verification

- XSim 2025.2 active test passed at seed 1 with
  `active=1 driver=1 monitor=1`.
- XSim 2025.2 passive test passed at seed 1 with
  `active=0 driver=0 monitor=1`.
- The completed decision fixture passed its structural check.
- The incomplete fixture failed because TODO decisions remained.
- The learner's partial decision file is preserved as optional notes.

## Completion evidence

- The learner assigned pin driving to the active block-level agent and retained
  the monitor in passive subsystem reuse.
- The learner explained that two active agents driving the same DUT pins create
  races and conflicting ownership.
- Requiring the remainder of the worksheet or reflection would add clerical
  work without new implementation or transfer evidence.

## Assessment boundary

- Structural completion does not establish semantic correctness.
- Reject any answer that permits multiple pin-driving owners or removes passive
  observation merely because the driver is absent.
