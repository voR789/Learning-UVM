# UI-01 Implementation Handoff

Updated: 2026-07-22

## Status

- UI-01 is the current focus after guided completion of FV-G1.
- The learner explicitly reported no prior UVM knowledge and requested reading plus a worked example before implementation.
- This module is teach-first and conceptual. Do not ask the learner to construct a full UVM environment.
- The local reading introduces objects versus components, responsibility ownership, broad build/connect/run lifecycle, and familiar transaction flow.
- `worked-example.md` maps a registered-command peripheral without supplying the learner-owned FV-G1 mapping worksheet.
- The executable XSim example demonstrates UVM hierarchy and role messages only; transaction connections are deferred to their roadmap modules.
- The learner owns only `exercise/architecture-map.md` and `reflection.md`.

## Coaching start

1. Ask the learner to read `reading/uvm-mental-model.md` through section 3.
2. Discuss one confusion at a time; teach unfamiliar concepts before using the hint ladder.
3. Ask the README prediction about short-lived intent versus persistent roles.
4. Continue through the worked example and run the executable hierarchy.
5. Review one worksheet row at a time without filling the table for the learner.

## Guardrails

- Do not require memorization of macros, factory syntax, phases, objections, or TLM APIs in UI-01.
- Do not describe the current FV-G1 tasks as classes or as UVM components.
- Preserve the distinction between a UVM factory mechanism and a UVM component role.
- Do not advance until the learner can explain that UVM standardizes structure but does not provide the specification-derived predictor.
