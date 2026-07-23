# UI-02 Progressive Hints

Reveal only one level at a time.

## Level 1: Diagnostic question

When `selected` is declared as `check_policy` but refers to a
`tolerance_policy`, which implementation does the call actually reach?

## Level 2: Concept

Runtime polymorphism requires a compatible override of a base method declared
`virtual`. The base handle restricts the visible contract; the runtime object
selects the implementation.

## Level 3: Location

Inspect the three `accept` methods and the two assignments to `selected` in
`tb/policy_lab.sv`. The caller task should not need modification.

## Level 4: Pseudocode

```text
exact accept = expected equals actual
difference = actual minus expected
if difference is negative, negate it
tolerant accept = difference no greater than configured tolerance
```

## Level 5: Minimal repair direction

Return the equality expression from the exact policy. In the tolerance policy,
calculate a signed difference, make it nonnegative, and compare it with the
stored tolerance. Preserve `virtual` on the base declaration.

## Level 6: Reference direction

Use `return expected == actual;` for exact comparison. For tolerant comparison,
compute `difference = actual - expected`, negate it when negative, and return
`difference <= tolerance`. Do not change `expect_decision` or add type tests.
