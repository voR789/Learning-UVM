# UI-11 Implementation Handoff

Updated: 2026-07-24

## Status

- UI-11 completed with guided evidence on 2026-07-25.
- Learner requested continued dense, hands-on coding.
- Learner owns `tb/ui11_pkg.sv` and `reflection.md`.
- UI-09 remains the official current focus until its exact trace formatting is
  corrected; UI-11 creation does not waive that module contract.

## Intended practice

- Implement reusable configurable leaf sequence behavior.
- Compose two ordered children through `m_sequencer` and parent context.
- Reuse the explicit UI-07 item/driver handshake.
- Diagnose missing composition through deterministic timeout evidence.

## Verification

- Valid fixture passed XSim 2025.2 at seed 1 with six ordered completed items,
  two completed subsequences, and zero UVM errors/fatals.
- Missing-subsequence fixture compiled and elaborated, then timed out at 1 us
  because the driver remained blocked waiting for items four through six.
- Untouched learner starter compiles and elaborates, then fails because it
  emits no completion evidence or pass marker.
- Final learner run passed at seed 1 with six completed items, two completed
  subsequences, zero UVM errors/fatals, and the exact sequence trace.

## Guardrails

- Do not fill learner TODOs without an explicit request after an attempt.
- Do not use sequence convenience macros.
- Preserve exactly one acknowledgment per accepted item.
