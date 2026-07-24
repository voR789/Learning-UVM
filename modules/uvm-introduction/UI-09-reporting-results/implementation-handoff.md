# UI-09 Implementation Handoff

Updated: 2026-07-23

## Status

- UI-09 learner implementation and reflection are complete except for exact
  `REPORT_TRACE` formatting; the documented run otherwise passes.
- Learner requested substantially more hands-on work than UI-08.
- Learner owns report classification, verbosity configuration, report-server
  count inspection, objection handling, and final verdict logic in
  `tb/ui09_pkg.sv`, plus `reflection.md`.

## Teaching shape

- Short reporting mental model and a separate parser worked example.
- One prediction about pass-marker versus UVM-error authority.
- Ten TODO regions containing multiple control-flow and lifecycle decisions,
  rather than a small connection worksheet.

## Verification

- Valid fixture passed XSim 2025.2 at seed 1 with three matches, one warning,
  zero errors/fatals, four attempted high-detail reports, and the exact pass
  trace.
- Error-with-pass-marker fixture compiled, elaborated, printed
  `TEST_RESULT: PASS`, and was correctly rejected because the UVM summary
  contained one `UI09_MISMATCH` error.
- Untouched learner starter compiled and elaborated, then failed as intended
  because it emitted no final pass marker.
- Learner run on 2026-07-24 passed with three matches, one retry warning, four
  detail attempts, zero mismatches/errors/fatals, and correct verbosity checks.
- The learner trace currently includes spaces around `=` and commas, so it does
  not yet match the exact module-contract trace text.

## Guardrails

- Do not fill learner TODOs without an explicit request after an attempt.
- Do not weaken expected local/global counts.
- A pass marker never overrides UVM errors or fatals.
