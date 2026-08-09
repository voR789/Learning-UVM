# DV-C1 implementation handoff

## 2026-08-06 — creation milestone

- Roadmap contract: blind 1200-minute portfolio capstone, prerequisite DV-03.
- Evidence-first novelty: APB/RAL integration, passive checking, regression
  triage, and coverage disposition are already proven. The new transfer is
  independently deriving an environment for a tagged, decoupled command/response
  protocol and retaining obligations correctly under independent backpressure.
- Learner owns the plan, all UVM implementation, and concise report. No generic
  reflection or duplicate evidence summary is required.
- Codex supplies only the specification, RTL, top shell, runner, opaque fault
  selection, non-UVM reference contract check, rubric, and progressive hints.
- XSim 2025.2 seed-1 reference passed six independent command/response checks,
  including response backpressure and reset recovery, with `TEST_RESULT: PASS`.
- The same reference sequence against opaque F1 returned nonzero through
  `DVC1_REF_MISMATCH` on a transferred response.
- The first fixture attempt exposed active-region races in the procedural
  driver. Moving stimulus transitions and pre-transfer sampling to falling
  edges made the reference evidence deterministic without changing the DUT.
- Progress remains `not_started`; no learner executable evidence or report
  exists.

## 2026-08-08 — test-name contract update

- Learner selected the runner-facing scenario names `tcs_smoke_test`,
  `tcs_reset_test`, `tcs_op_test`, `tcs_protocol_test`, and `tcs_stress_test`
  to match the learner-owned architecture plan.
- The default learner command is now `./run.ps1 -Test tcs_smoke_test -Seed 1`.
- Reference-fixture test naming remains independent and unchanged.

## 2026-08-07 — plan framework milestone

- At the learner's request, the learner-owned plan now has blank concise
  Siemens-style traceability and execution-table headers. All entries and
  design decisions remain learner-owned.

## 2026-08-08 - command-drive policy decision

- The learner's plan now separates functional command intent from command-handshake mechanics.
- `cmd_req` is planned to carry payload plus `HOLD_UNTIL_ACCEPT` (default) or
  `PULSE_ONE_CYCLE`; the command driver owns `cmd_valid`, safe-edge timing,
  and normal hold behavior.
- `TC-FULL-01` uses four normal commands and a fifth one-cycle unaccepted
  probe. Only a passive command handshake creates a predictor expectation.
- This is planning only: no learner-owned testbench code or progress changed.
