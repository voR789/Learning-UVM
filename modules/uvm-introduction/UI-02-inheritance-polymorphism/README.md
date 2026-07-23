# UI-02: Inheritance and polymorphism for verification

## Why this matters

Verification environments often need interchangeable policies: exact versus
tolerant comparison, normal versus fault-injection driving, or concise versus
verbose formatting. Copying the caller for every policy makes behavior hard to
replace and test. Inheritance shares a contract; polymorphism lets one caller
use different implementations through that contract.

This is teach-first. You are not expected to guess class syntax. Read the local
mental model, walk through the separate formatter example, and answer the
prediction before editing the learner-owned lab.

## Observable contract

The lab checks integer observations with two policies:

- `exact_policy` accepts only `actual == expected`;
- `tolerance_policy` accepts values whose absolute difference is at most its
  configured tolerance;
- the caller receives a `check_policy` base handle and must not branch on the
  derived type;
- a virtual method must dispatch to the actual derived object;
- the lab must prove exact match, near match, and clear mismatch behavior.

## Learning path

1. Read `reading/inheritance-mental-model.md`.
2. Walk through `worked-example.md` and make its prediction.
3. Run the starter and observe the intentional self-check failure.
4. Complete the TODOs in `tb/policy_lab.sv`.
5. Re-run until the self-checking lab passes.
6. Complete `reflection.md` in your own words.

## Run

```powershell
cd "C:\Learning UVM\modules\uvm-introduction\UI-02-inheritance-polymorphism"
.\run.ps1
```

If local PowerShell policy blocks scripts, use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run.ps1
```

The runner prints the test name and seed and returns nonzero for compile,
elaboration, timeout, or self-check failure. The starter is intentionally
incomplete and should fail after compiling.

## Constraints

- Do not add UVM macros or factory calls; UI-03 introduces them.
- Do not use type tests or a `case` statement in the common caller.
- Preserve the base-handle caller and let virtual dispatch choose behavior.
- Do not alter the required observations merely to make the lab pass.

## Completion

Completion requires a passing run, semantic review, and the reflection. Expected
time is about 75 minutes.

## Prediction before implementation

If a `check_policy` base handle points to a `tolerance_policy` object, which
implementation should `policy.accept(10, 11)` call, and what language feature
makes that happen?
