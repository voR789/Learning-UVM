# UI-10 Implementation Handoff

Updated: 2026-07-24

## Status

- UI-10 scaffolded as the next roadmap unit after UI-09.
- Learner requested continued dense, hands-on coding.
- Learner owns `tb/ui10_pkg.sv` and `reflection.md`.

## Intended practice

- Reuse UI-08 analysis publication and connection without full scaffolding.
- Build an FV-07-style requirement-derived covergroup inside a UVM subscriber.
- Implement exactly-once sampling in `write()`.
- Diagnose publication, connection, sampling, and coverage closure from
  separate evidence.

## Verification

- Valid fixture passed XSim 2025.2 at seed 1 with eight publications, eight
  samples, 100.00% coverage, zero UVM errors/fatals, and a generated functional
  coverage report.
- Missing-cross-combination fixture compiled and elaborated, then failed at
  95.83% coverage with `UI10_COVERAGE`.
- XSim 2025.2 requires an embedded class covergroup to be constructed and
  accessed through its declaration name; it cannot be redeclared as a separate
  covergroup-typed handle.
- Untouched learner starter compiles and elaborates, then fails because required
  environment children are absent.

## Guardrails

- Do not fill learner TODOs without an explicit request after an attempt.
- Do not sample publisher intent or add a second sample call.
- Preserve the 100% cross-closure requirement.
