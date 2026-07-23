# UI-03 Implementation Handoff

Updated: 2026-07-22

## Status

- UI-03 completed with guided evidence on 2026-07-22; UI-04 is now the current focus.
- The learner requested continued work in UVM syntax.
- This module is teach-first and separates import, include, registration,
  construction, and compile-order concepts.
- The learner owns `tb/ui03_pkg.sv`, `exercise/syntax-map.md`, and
  `reflection.md`.

## Completion evidence

- Final learner run passed at seed 1 with registered type `ui03_packet`, object
  name `packet`, value 42, and a passing five-row syntax map.
- The learner distinguished package compilation, import visibility, textual
  macro inclusion, registration, factory construction, and factory overrides.
- Reflection was accepted without another rewrite; it omitted the explicit
  sentence that registration alone creates no instance, which was already
  demonstrated correctly during coached practice.
- Progress recorded as `guided`, score 92.

## Coaching start

1. Teach the observable four-question compiler model in the local reading.
2. Walk through the separate `audit_record` example.
3. Ask its missing-include prediction before running the learner starter.
4. Have the learner classify the starter compiler error before editing.
5. Review the syntax map one row at a time without filling it in.

## Verification status

- XSim 2025.2 valid registered-object fixture passed at seed 1 on 2026-07-22
  with type `ui03_packet`, name `packet`, and value 42.
- Reversed compilation order failed as intended because `tb_top.sv` could not
  resolve `ui03_pkg` or `ui03_packet`.
- The learner starter failed as intended because unregistered `ui03_packet`
  does not provide `type_id`.
- `tests/verify-fixtures.ps1` reports
  `FIXTURE_RESULT: PASS valid=passed reverse_order=failed_as_intended map=passed`.

## Guardrails

- Do not conflate the UVM factory mechanism with a persistent component role.
- Do not claim import compiles a package or include imports declarations.
- Do not let the learner bypass registration by changing the caller to `new`.
- Do not introduce component hierarchy or phase implementation before UI-04.
