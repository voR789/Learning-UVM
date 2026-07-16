# FV-01: Read a specification and write a verification plan

## Why this matters

A testbench can execute many vectors and still miss the behavior the specification actually requires. A verification plan creates traceability from each requirement to stimulus, observations, expected results, and an explicit failure condition before implementation begins.

## Behavioral specification

Read [dut/alu-spec.md](dut/alu-spec.md). Treat it as authoritative. Do not infer behavior from a future RTL implementation; no RTL is provided in this module.

This planning target will support a later self-checking testbench exercise, so write cases that could be implemented directly rather than vague goals such as "test addition."

## Your task

Complete [plan/verification-plan.md](plan/verification-plan.md) in your own words.

For every requirement ID in the specification:

- Identify purposeful stimulus, including relevant boundaries.
- Name the outputs that must be observed.
- Calculate or describe the expected result independently of the DUT.
- State an observable pass/fail rule.
- Include meaningful negative cases, especially invalid operations.

You may add rows and sections. Do not delete the required headings or table columns.

## Constraints and allowed references

- Expected time: about 60 minutes.
- Use the specification and your SystemVerilog/RTL knowledge.
- Do not inspect or request an ALU implementation; the plan must come from the contract.
- This module requires a plan, not SystemVerilog or UVM code.

## Run the structural check

```powershell
.\run.ps1
```

The command checks required headings, unresolved TODO markers, table shape, and traceability to every requirement ID. It cannot determine whether your expected values or test intent are technically correct; that requires review against the rubric.

This planning-only module intentionally does not invoke XSim because it has no HDL deliverable. The checker itself has a known-pass and known-fail self-test under `tests/`.

## Completion criteria

- `run.ps1` returns zero and prints `PLAN_CHECK_RESULT: PASS`.
- Every specification requirement is covered by at least one implementable test case.
- Boundary and invalid-operation behavior are explicit.
- Each case identifies stimulus, observation, expected behavior, and failure criteria.
- `reflection.md` is completed in your own words.

## Prediction

Before writing the plan, identify one incorrect ALU implementation that could still pass if you tested each valid operation with only one ordinary input pair. What additional kind of case would expose it?
