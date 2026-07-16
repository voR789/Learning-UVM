# FV-01 Hints

Use one level at a time.

## Level 1: Diagnostic question

For each requirement, what incorrect implementation could satisfy your ordinary cases but fail at a boundary or flag transition?

## Level 2: Concept or invariant

Traceability means every requirement has a test intent, and every test has observable expected behavior and a failure rule.

## Level 3: Location

Compare the requirement IDs in `dut/alu-spec.md` with the rows in `plan/verification-plan.md`. Then inspect the `Stimulus`, `Observations`, `Expected result`, and `Failure criterion` columns independently.

## Level 4: Pseudocode

```text
for each requirement:
    identify ordinary behavior
    identify boundary or negative behavior
    choose concrete inputs
    predict outputs from the specification
    name the observed outputs
    state exactly what constitutes failure
```

## Level 5: Minimal repair direction

Split any row that contains multiple unrelated behaviors. Add concrete operand classes or values wherever a future testbench author would otherwise have to guess.

## Level 6: Reference solution

A completed plan is intentionally not stored in the starter module. Request an explicit reference review only after submitting and discussing your own plan.
