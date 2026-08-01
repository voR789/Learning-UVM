# UA-05 implementation handoff

Updated: 2026-07-31

## Status

- UA-05 is complete with guided evidence; UA-06 is now the next eligible module.
- UI-11 already proves sequential hierarchical composition, and UB-06/UB-G1
  prove response routing. The only retained implementation is concurrent child
  lifecycle management on a shared sequencer.
- The learner completed the concurrent parent body in
  `ua05_parallel_sequence::body()` plus the reflection.

## First action

Read `resources/parallel-sequence-lifecycle.md` and answer its prediction before
editing.

## Verification boundary

- Both child sequences must reach the supplied rendezvous before either issues
  traffic.
- Each child must verify three responses; the driver must handle three items per
  lane without requiring a fixed global interleaving.
- The sequential-child fixture must fail through `UA05_CONCURRENCY`.
- XSim 2025.2 seed 1 passed the parallel reference with two rendezvous
  arrivals, three verified responses per child, and six driven items.
- XSim 2025.2 seed 1 rejected sequential child starts through
  `UA05_CONCURRENCY` after the first child waited 10 ns for the second.
- The untouched learner starter compiles and intentionally fails through
  `UA05_COUNT` with zero arrivals and zero driven items.
- Learner source passed XSim 2025.2 at seed 1 with two rendezvous arrivals,
  three verified responses per child, six driven items, and zero UVM
  errors/fatals.
- The sequential-child fixture rejected missing lifecycle concurrency through
  `UA05_CONCURRENCY` at seed 1.

## Ownership

Preserve learner ownership of `tb/ua05_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
