# UA-10 implementation handoff

Updated: 2026-08-03

## Status

- UA-10 is scaffolded and remains `not_started`.
- UA-08/09 already prove RAL construction, routing, prediction, access paths,
  and state coherence.
- Evidence-first novelty review supplies all repeated model, bus, adapter,
  environment, and test-lifecycle code.
- Learner work is one `uvm_reg_sequence::body()` plus reflection.

## New invariant

Two logical `uvm_mem` indices must remain independently addressable. The
sequence must retain distinct expectations and compare later readbacks; status
alone is insufficient.

## Coverage checkpoint

RAL coverage API transcription is reading-only. The learner must explain that
coverage-management flags enable an implemented sampling model but do not
create covergroups. Later UA-G1 will require transferred coverage intent in an
integration environment.

## Verification boundary

- A reference sequence must write and verify two distinct memory indices in
  four frontdoor operations.
- An address-alias driver must fail through `UA10_DATA`.
- The untouched starter must fail through `UA10_RESULT`.
- XSim 2025.2 seed 1 passed the reference flow with
  `mem0=0xD00D0001`, `mem1=0xC0DE0002`, two verified readbacks, four
  frontdoor operations, and zero UVM errors/fatals.
- The address-alias fixture failed through `UA10_DATA` on the index-0
  readback, and the untouched starter failed through `UA10_RESULT`.

## Ownership

Preserve learner ownership of `tb/ua10_pkg.sv` and `reflection.md`. Use one
hint-ladder level per learner turn unless stronger help is explicitly requested.
