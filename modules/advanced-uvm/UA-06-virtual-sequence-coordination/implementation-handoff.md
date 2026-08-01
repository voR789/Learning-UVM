# UA-06 implementation handoff

Updated: 2026-07-31

## Status

- UA-06 is complete with guided evidence; UA-07 is now the eligible current focus.
- Coordinating two typed physical sequencers through a virtual sequencer is new
  implementation behavior and is retained.
- Protocol-layer translation is a reading checkpoint because no current target
  requires an upper-to-lower protocol adapter.
- Learner work is limited to virtual-sequencer handle wiring, two leaf starts,
  and the reflection.

## First action

Read `resources/virtual-versus-layered-sequences.md` and answer its prediction
before editing.

## Verification boundary

- Control and data leaf sequences run under one virtual sequence on different
  typed sequencers.
- Data waits for the acknowledged control enable event.
- The missing-data-handle fixture fails through `UA06_VSEQR` before protocol
  traffic can stall.
- XSim 2025.2 seed 1 passed the reference virtual coordination flow with one
  acknowledged control item, three verified data items, and zero UVM
  errors/fatals.
- XSim 2025.2 seed 1 rejected the missing-data-handle fixture immediately
  through `UA06_VSEQR`.
- The untouched learner starter compiles and intentionally fails through
  `UA06_VSEQR` because neither physical handle is wired yet.
- Learner completion run passed in XSim 2025.2 at seed 1 with
  `control_verified=1`, `data_verified=3`, `control_driven=1`, and
  `data_driven=3`; UVM reported zero errors and fatals.
- The documented missing-data-handle fixture returned nonzero at time 0 through
  `UA06_VSEQR` after learner completion.

## Ownership

Preserve learner ownership of `tb/ua06_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
