# UA-G1 implementation handoff

Updated: 2026-08-05

## Status

- UA-G1 is complete as `guided` with a score of 98/100.
- Prerequisites UA-07 and UA-10 are complete as `guided`.
- The gate is intentionally compressed from the roadmap estimate: repeated APB
  construction, RAL definitions, adapter, driver, environment construction,
  and base-test lifecycle are supplied.

## Evidence-first novelty

Prior modules prove each mechanism in isolation. The new transfer invariant is
that one passive APB observation must independently drive RAL prediction,
functional checking, and coverage while a response-driven scenario and an
explicit scoreboard drain own control and termination.

## Learner boundary

- `tb/ua_g1_pkg.sv`: four behavioral TODO regions.
- `plan/verification-plan.md`: three requirement-specific decisions.
- `reports/evidence-summary.md` and `reflection.md`.

Preserve learner ownership. Use one hint-ladder level per turn unless stronger
help is explicitly requested.

## Learner planning milestone

- The three requirement-specific verification-plan decisions were reviewed and
  completed on 2026-08-04. Do not request another plan review unless the
  learner changes those decisions or the DUT contract changes.

## Verification boundary

- XSim 2025.2 seed 1 reference passed with 10 observed/driven transfers,
  two checked results, two status polls, complete required coverage flags, and
  zero UVM errors/fatals.
- The incorrect result DUT failed first through passive `UAG1_MISMATCH` with
  expected `0x60` and observed `0x61`; the scenario subsequently rejected the
  same bad read.
- The untouched starter failed immediately through `UAG1_TODO` in the passive
  monitor.
- During fixture validation, sampling `pslverr` after the APB completion edge
  exposed a stale-response bug in the supplied agent. The driver and monitor
  now sample response signals on the completion edge, matching the local
  interface contract.

## Completion evidence

- Learner XSim 2025.2 seed 1 passed on 2026-08-05 with `checked=2`,
  `mismatches=0`, `observed=10`, `driven=10`, and zero UVM errors/fatals.
- An assessment-only run of the learner testbench against the faulty DUT at
  seed 1 failed through learner-owned `UAG1_MISMATCH` on RESULT, then
  `UAG1_RESULT` with `mismatches=1`.
- The documented direct fault fixture also failed as intended at seed 1.
- The learner completed the plan, evidence summary, and reflection. Next
  eligible roadmap module: `DV-01`.
