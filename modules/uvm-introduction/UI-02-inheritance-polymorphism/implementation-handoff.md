# UI-02 Implementation Handoff

Updated: 2026-07-22

## Status

- UI-02 completed with guided evidence on 2026-07-22; UI-03 is now the current focus.
- The learner reported that class construction and inheritance rules remain
  unclear, so this module is teach-first.
- The module intentionally uses plain SystemVerilog classes. UVM factory
  registration and macros are deferred to UI-03.
- The learner owns `tb/policy_lab.sv` and `reflection.md`.

## Completion evidence

- Final learner implementation passed all six exact and tolerance policy checks
  in XSim 2025.2 at seed 1.
- One unchanged base-handle caller dispatched to both derived overrides.
- The learner corrected exact equality so matching unknowns are not accepted.
- Reflection was accepted with a terminology gap around non-virtual method
  hiding versus runtime overriding.
- Progress recorded as `guided`, score 94.

## Coaching start

1. Teach `reading/inheritance-mental-model.md` through the four separate ideas.
2. Walk through the formatter example without converting it into the policy-lab
   solution.
3. Ask the worked-example prediction before learner implementation.
4. Run the starter and localize the observable failed policy cases.
5. Coach one TODO or misconception at a time using the hint ladder.

## Verification status

- XSim 2025.2 valid polymorphism fixture passed six checks at seed 1 on
  2026-07-22.
- The non-virtual base-method fixture failed specifically on base-handle
  dispatch of the tolerance near-match behavior.
- The learner starter compiled and elaborated, then failed intentionally with
  three policy mismatches because the incomplete methods return false.
- `tests/verify-fixtures.ps1` reports
  `FIXTURE_RESULT: PASS valid=passed invalid=failed_as_intended`.

## Guardrails

- Do not introduce UVM factory or macro syntax in UI-02.
- Do not let the common caller branch on derived types.
- Do not fill learner TODOs without explicit permission after an attempt.
- Preserve the distinction between inheritance and virtual dispatch.
