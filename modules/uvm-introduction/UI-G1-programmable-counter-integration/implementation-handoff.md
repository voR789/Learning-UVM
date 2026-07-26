# UI-G1 Implementation Handoff

Updated: 2026-07-25

## Status

- UI-G1 scaffolded after completion of UI-09, UI-10, and UI-11.
- This is a 3–8 hour integration gate with reduced scaffolding.
- Learner owns the verification plan, UVM package, and reflection.

## Repeated practice

- UI-04/UI-05 hierarchy and environment composition.
- UI-07/UI-11 sequence, sequencer, driver, and composition.
- UI-08 analysis broadcast and independent consumers.
- UI-10 subscriber-based functional coverage.
- UI-09 report counts and deterministic verdicts.
- FV-G1 passive observation and independent prediction.

## Verification

- Known-good fixture passed XSim 2025.2 at seed 1.
- Scenario revised to nine operations so RESET clears an observed `8'hFF`
  sentinel and both arithmetic wrap directions are exercised.
- Revised known-good fixture passed XSim 2025.2 at seed 1 with
  `driven=9 observed=9 checked=9 sampled=9 coverage=100.00 errors=0 fatals=0`.
- Revised faulty decrement-as-increment DUT failed at the scoreboard with
  `COUNT_MISMATCH`: expected 6, observed 8.
- Faulty decrement-as-increment DUT failed at the scoreboard with
  `COUNT_MISMATCH`: expected 6, observed 8.
- The learner starter intentionally remains incomplete and its TODOs were not
  filled.

## Guardrails

- Do not fill learner TODOs without an explicit request after an attempt.
- Monitor observation, not driver intent, feeds scoreboard and coverage.
- Do not weaken the faulty-DUT oracle or completion counts.
