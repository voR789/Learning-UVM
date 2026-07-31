# UB-G1 implementation handoff

Updated: 2026-07-30

## Completion assessment

- Learner source passed XSim 2025.2 at seed 1: 23 responses including the
  stop response, 22 driven/observed/checked DUT operations, 100% coverage, and
  zero UVM errors/fatals.
- The same source rejected the early-full FIFO with `UBG1_MISMATCH` at modeled
  occupancy three. The supplied DUT-status coverage model then reported 95%; it
  is a known scaffolding limitation rather than the pass/fail oracle.
- Learner completed reflection and evidence summary. UB-G1 is assessed as
  guided, score 94/100; next eligible module is UA-01.

## Status

- UB-G1 is the next eligible UVM Basics integration gate after guided UB-08 completion.
- The evidence-first novelty check retained implementation because this is a
  cross-context transfer: plain-SV FIFO checking plus UVM architecture plus a
  real status-driven response path.
- Repeated verification-plan work, construction, connections, coverage,
  reporting, and verdict mechanics are supplied.
- Learner work is limited to four behavioral TODO regions in `tb/ub_g1_pkg.sv`.

## First action

Read `resources/status-driven-sequences.md` and answer its prediction before
editing learner-owned code.

## Verification boundary

- Known-good XSim 2025.2 fixture passed at seed 1 with 27 responses including
  the stop response, 26 driven/observed/checked DUT operations, 100% functional
  coverage, and zero UVM errors/fatals.
- The same valid package rejected the early-full FIFO through
  `UBG1_MISMATCH`; the first mismatch occurred when `full` asserted at modeled
  occupancy three.
- The untouched learner starter compiled and elaborated, then failed
  intentionally at `UBG1_TODO`.

## Ownership

Preserve learner ownership of `tb/ub_g1_pkg.sv`, `reflection.md`, and
`reports/evidence-summary.md`. Use one hint-ladder level per learner turn unless
the learner explicitly requests stronger help.
