# FV-07 Progressive hints

## Level 1 — Diagnostic question

Which requirement-derived scenario could be absent even though every sampled transaction passed its checker?

## Level 2 — Concept

Coverpoints classify one dimension. Crosses measure whether meaningful combinations of dimensions occurred.

## Level 3 — Location

Define bins inside `alu_cg`; sample only in `sample_transaction`; add closure stimulus only after inspecting holes.

## Level 4 — Pseudocode

```text
operation coverpoint: one bin per encoding
operand coverpoint: zero / middle / maximum
zero coverpoint: false / true
cross: defined operation bins x zero bins
```

## Level 5 — Minimal repair direction

Ask for review of one attempted coverpoint, bin set, cross, or reported hole.

## Level 6 — Reference solution

Available only after an explicit request and an explained attempt.
