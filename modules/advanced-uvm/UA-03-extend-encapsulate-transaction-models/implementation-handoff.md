# UA-03 implementation handoff

Updated: 2026-07-31

## Status

- UA-03 is complete with guided evidence; UA-04 is now the next eligible module.
- UB-05 already established ordinary transaction-object behavior, so this
  exercise is deliberately limited to the new inheritance-layer invariant.
- The learner completed the three related behavioral methods in `tb/ua03_pkg.sv`
  plus the reflection.

## First action

Read `resources/extended-transaction-models.md` and answer its prediction
before editing.

## Verification boundary

- A valid extended transaction must copy and compare base plus burst state.
- A changed burst field must be detected after copying.
- A supplied subclass that omits burst state must fail through `UA03_COPY`.
- XSim 2025.2 seed 1 passed the independent known-good fixture with zero UVM
  errors/fatals.
- XSim 2025.2 seed 1 rejected the extension-loss fixture through `UA03_COPY`.
- The untouched learner starter compiles and intentionally fails through
  `UA03_VALID` until derived validation is implemented.
- Learner source passed XSim 2025.2 at seed 1 with zero UVM errors/fatals.
- The same source rejected the extension-loss fixture through `UA03_COPY` at
  seed 1 after the fixture deliberately dropped burst-only state.

## Ownership

Preserve learner ownership of `tb/ua03_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless the learner explicitly asks for more.
