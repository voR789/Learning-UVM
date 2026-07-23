# UI-06 Implementation Handoff

Updated: 2026-07-23

## Status

- UI-06 is current focus after guided UI-05 completion.
- Learner requested faster progression; this module combines ports, exports,
  imps, FIFO buffering, connect phase, blocking calls, and a completion barrier.
- Learner owns `tb/ui06_pkg.sv` and `reflection.md`.

## Coaching start

1. Read the compact port/export/imp model and answer its coupling question.
2. Trace the separate logger example and predict the executing task body.
3. Run the starter and interpret unconnected-port diagnostics.
4. Implement only the three connect-phase TODOs.
5. Require one consumer and one audit check before reflection.

## Verification status

- XSim 2025.2 valid fixture passed at seed 1 with one consumer check, one
  audit check, drained FIFO, and zero UVM errors/fatals.
- Misroute fixture connected the audit output to the FIFO instead of the audit
  imp and failed at the 1 us timeout because the audit/barrier path never
  completed.
- The starter compiled and elaborated, then failed at time zero with three
  unconnected-port errors and the UVM build-error fatal.

## Guardrails

- Do not replace TLM with direct component method calls.
- Do not introduce analysis broadcast; UI-08 owns that model.
- Do not weaken barrier completion or destination counts.
- Preserve explicit null guards for XSim-targeted maybe-null dereferences.
