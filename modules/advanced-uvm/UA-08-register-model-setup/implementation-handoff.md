# UA-08 implementation handoff

Updated: 2026-08-03

## Status

- UA-08 is complete with a `guided` assessment and score of 100/100.
- Register-model construction and frontdoor/predictor integration are new
  behavioral work and are retained.
- Field definitions, bus components, adapter implementation, test lifecycle,
  and verdict checks are supplied to avoid repeating mature mechanics.
- Learner work was two bounded TODO regions plus reflection.
- The RAL resource was expanded on 2026-08-02 with API names, parameter
  meanings, lifecycle order, and a separate timer example after the learner
  identified that the original conceptual reading was insufficient.
- The same resource was further expanded on 2026-08-02 with the full frontdoor
  and observation paths, a distinction between TLM connections, handle
  assignments, and routing registration, plus a missing-connection diagnostic
  table.

## Next module

UA-09 is eligible and is the current focus. It will extend this model with
frontdoor/backdoor access and mirror/predict/update behavior.

## Verification boundary

- A reference register model must write control offset `0x0` through the bus and
  update the mirror from completed traffic.
- A model mapped at `0x4` must fail through `UA08_STATUS`.
- The learner starter must fail through `UA08_MODEL`.
- XSim 2025.2 seed 1 passed the single reference flow with stored control
  `0x5`, mirrored control `0x5`, one completed bus operation, and zero UVM
  errors/fatals.
- XSim 2025.2 seed 1 rejected the wrong-offset fixture through `UA08_STATUS`.
- The untouched learner starter compiled and elaborated, then failed through
  `UA08_MODEL` because the control register was not built.
- The learner implementation passed XSim 2025.2 at seed 1 on 2026-08-03 with
  stored control `0x5`, mirrored control `0x5`, one completed operation, and
  zero UVM errors or fatals.
- The documented wrong-offset fixture returned nonzero through `UA08_STATUS` on
  2026-08-03.

## Ownership

Preserve learner ownership of `tb/ua08_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
