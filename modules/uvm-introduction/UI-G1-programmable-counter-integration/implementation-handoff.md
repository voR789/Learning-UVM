# UI-G1 Implementation Handoff

Updated: 2026-07-27

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
- Scenario revised to thirteen operations to match the completed verification
  plan, including reset from `8'hFF`, CLEAR persistence, nonzero HOLD retention,
  normal INC/DEC, and both arithmetic wrap directions.
- Coverage now requires command/result and valid/result crosses.
- XSim 2025.2 could not elaborate `cross_auto_bin_max=0`; the compatible
  implementation uses explicit required bins and explicitly ignored remaining
  combinations.
- Revised known-good fixture passed at seed 1 with
  `driven=13 observed=13 checked=13 sampled=13 coverage=100.00 errors=0 fatals=0`.
- Revised faulty decrement-as-increment DUT failed with `COUNT_MISMATCH`:
  expected 4, observed 6.
- The learner starter intentionally remains incomplete and its TODOs were not
  filled.
- Added `resources/config-db.md` before TODOs 2 and 4 after identifying that
  `uvm_config_db` had not been explicitly taught. The README links it before
  implementation work requiring a virtual interface.
- Learner implementation passed the known-good DUT in XSim 2025.2 at seed 1 on
  2026-07-27 with 13 driven, observed, checked, and sampled transactions, 100%
  functional coverage, and zero UVM errors/fatals.
- The same learner implementation rejected the decrement-as-increment DUT at
  115 ns with expected count 4 and observed count 6.
- Final learner source passed XSim 2025.2 at seed 1 on 2026-07-27 with exact
  `driven=13 observed=13 checked=13 sampled=13 coverage=100.00 errors=0 fatals=0`.
- The same saved learner source rejected the decrement-as-increment DUT at
  115 ns with `U1_G1_MISMATCH` and a nonzero runner result.
- UI-G1 was assessed at 94/100 with guided evidence and recorded complete;
  `current_focus` advanced to UB-01.

## Guardrails

- Do not fill learner TODOs without an explicit request after an attempt.
- Monitor observation, not driver intent, feeds scoreboard and coverage.
- Do not weaken the faulty-DUT oracle or completion counts.

## Forward coaching preference

- The learner selected UA-04 as the approximately 27-focused-hour milestone
  before applying UVM to systolic-array RTL.
- Starting after UI-G1, pre-complete mature, lengthy process artifacts when they
  are not the objective, especially repeated verification-plan boilerplate.
- Keep brief mechanical retrieval such as registration and object creation.
- Provide structural skeletons and empty method signatures, with broader
  outcome-based TODOs and less proactive implementation guidance.
