# UA-G1 implementation handoff

Updated: 2026-08-03

## Status

- UA-G1 is scaffolded, XSim-verified, and remains `not_started`.
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
