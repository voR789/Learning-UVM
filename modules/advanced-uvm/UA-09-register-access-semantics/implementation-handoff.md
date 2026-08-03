# UA-09 implementation handoff

Updated: 2026-08-03

## Status

- UA-09 is complete with a `guided` assessment and score of 100/100.
- UA-08 already proves register construction, mapping, adapter translation,
  sequencer binding, and observed frontdoor prediction.
- Evidence-first novelty review removed all repeated RAL architecture from
  learner work.
- Learner work was limited to three small state-transition methods plus
  reflection. Staging and committing are separate so the supplied checker can
  prove that `set()` generated no bus traffic.

## New invariant

The learner must distinguish observation from assertion and manage actual,
mirrored, and desired state intentionally:

- resynchronize from an external implementation change through a supplied
  backdoor observation followed by `predict()`;
- stage with `set()` and commit with frontdoor `update()`.

## Verification boundary

- Reference behavior must finish with actual, mirrored, and desired values at
  `0x3`, two frontdoor operations, and one backdoor read.
- Predicting `0x6` without a backdoor observation must fail through
  `UA09_SYNC`.
- The untouched learner starter must fail through `UA09_SYNC`.
- Initial XSim 2025.2 probing showed that the packaged UVM base
  `uvm_reg_backdoor::read()` calls its own fatal `read_func()` instead of
  dispatching the derived override. The module therefore exposes the equivalent
  observation-plus-prediction responsibilities explicitly.
- XSim 2025.2 seed 1 passed the reference flow with actual, mirrored, and
  desired values at `0x3`, two frontdoor operations, one backdoor read, and
  zero UVM errors/fatals.
- The predict-without-observation fixture and untouched learner starter both
  failed through `UA09_SYNC`.
- The learner run passed XSim 2025.2 at seed 1 on 2026-08-03 with actual,
  mirrored, and desired values at `0x3`, two frontdoor operations, one
  backdoor read, and zero UVM errors or fatals. The learner then made a
  punctuation-only `void'(...)` result-discard repair, reviewed without a
  redundant rerun at the learner's request.
- The documented predict-without-observation fixture returned nonzero through
  `UA09_SYNC` on 2026-08-03.

## Ownership

Preserve learner ownership of `tb/ua09_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
