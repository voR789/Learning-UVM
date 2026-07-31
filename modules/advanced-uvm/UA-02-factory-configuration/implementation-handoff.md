# UA-02 implementation handoff

Updated: 2026-07-30

## Status

- UA-02 is the next substantive module after the completed UA-01 checkpoint.
- Registration, factory `create()`, configuration objects, and config-db scope
  have prior evidence.
- Factory type and instance overrides are new executable behavior and justify
  implementation.
- Learner work is limited to two behavioral TODO regions in `tb/ua02_pkg.sv`
  plus the final reflection.

## First action

Read `resources/factory-versus-configuration.md` and answer its prediction
before editing.

The reading was expanded on 2026-07-30 at the learner's request. It now
includes factory mechanics, creation-order tracing, a separate two-agent
worked example, UA-02 result tracing, and a debugging decision tree. It is
teaching material only; the two learner TODO regions remain unchanged.

## Verification boundary

- XSim 2025.2 seed 1 passed global type replacement with
  `left=add/21 right=add/25`.
- XSim 2025.2 seed 1 passed one-path replacement with
  `left=base/18 right=xor/21`.
- The wrong instance path failed through `UA02_OVERRIDE`.
- The untouched learner package compiled, elaborated, and failed through
  `UA02_OVERRIDE` because neither override is installed.

## Ownership

Preserve learner ownership of `tb/ua02_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
