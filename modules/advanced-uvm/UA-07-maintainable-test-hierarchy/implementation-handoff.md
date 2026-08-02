# UA-07 implementation handoff

Updated: 2026-08-02

## Status

- UA-07 is complete with guided evidence; UA-08 is now the eligible current
  focus.
- The implementation exercise is retained because prior work proves individual
  test mechanics but not one base-owned lifecycle invariant reused across a test
  family.
- Repeated environment, transaction, sequence, response, derived-test, runner,
  and regression-matrix mechanics are supplied.
- Regression taxonomy is a reading/execution checkpoint rather than another
  learner-authored process artifact.

## Verification boundary

- Known-good smoke and stress fixtures must pass at the documented seeds.
- A derived test that bypasses the common lifecycle must fail through
  `UA07_CONTRACT`.
- The untouched learner starter must fail because the shared completion
  contract is not satisfied.
- XSim 2025.2 passed the reference smoke test at seed 1 and the reference
  stress test at seeds 1 and 17, with matching verified/driver counts and zero
  UVM errors/fatals.
- XSim 2025.2 rejected the bypass-common-run fixture through `UA07_CONTRACT`.
- The untouched learner starter compiled and elaborated, then failed
  intentionally through `UA07_CONTRACT` at time 0.
- Learner regression passed in XSim 2025.2 on 2026-08-02: smoke seed 1 and
  stress seeds 1 and 17 all completed with matching nonzero verified/driver
  counts and zero UVM errors/fatals.
- Learner package rejected the direct bypass-common-run fixture at seed 1
  through `UA07_CONTRACT`.

## Assessment

- Score: 99/100, `guided`.
- The learner centralized the lifecycle without introducing a derived
  `run_phase()`, used an explicit null guard, and explained the contract and
  test/seed reproduction correctly.
- Later independent reuse should include an explicit downstream
  scoreboard-drain condition rather than relying solely on leaf responses.
