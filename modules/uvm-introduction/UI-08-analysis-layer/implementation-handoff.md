# UI-08 Implementation Handoff

Updated: 2026-07-23

## Status

- UI-08 completed with guided evidence; UI-09 is now current focus.
- Learner implemented `tb/ui08_pkg.sv` and completed `reflection.md`.
- Teach-first reading and a separate temperature-sample worked example precede
  one prediction question and implementation.

## Intended practice

- Declare, construct, and call one `uvm_analysis_port`.
- Connect it in `connect_phase` to both a `uvm_subscriber` export and a custom
  component's `uvm_analysis_imp`.
- Observe that one nonblocking broadcast invokes multiple independent,
  zero-time receiver functions without request acknowledgment.

## Verification

- Valid fixture passed XSim 2025.2 at seed 1 with
  `published=3 subscriber_checks=3 audit_checks=3`, zero UVM errors, and zero
  UVM fatals.
- Missing-audit fixture compiled and elaborated, then failed at the independent
  count oracle with `expected 3/3/3 got 3/3/0`.
- Untouched learner starter compiled and elaborated, then failed as intended
  with `published=3 subscriber=0 audit=0`; this is not completion evidence.
- Final learner run passed XSim 2025.2 at seed 1 with
  `published=3 subscriber_checks=3 audit_checks=3` and zero UVM errors/fatals.

## Guardrails

- Do not fill learner TODOs without an explicit request after an attempt.
- Do not reveal the missing connection before diagnostic evidence.
- Preserve both consumer count checks; zero analysis subscribers are legal UVM,
  so module-level checking must catch a missing required consumer.
