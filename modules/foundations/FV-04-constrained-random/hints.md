# FV-04 Progressive hints

## Level 1 — Diagnostic question

What value does `randomize()` return when no solution exists, and what happens if you ignore it?

## Level 2 — Concept

Class fields marked `rand` participate in solving; constraints restrict the solution space rather than checking values afterward.

## Level 3 — Location

Put legality shared by every ordinary transaction in the class constraint. Put one-test targeting beside the relevant `randomize() with` call.

## Level 4 — Pseudocode

```text
if randomization failed
    count error
else
    validate generated invariant
    print transaction
    count check
```

## Level 5 — Minimal repair direction

Ask for review of one attempted constraint or failure check.

## Level 6 — Reference solution

Available only after an explicit request and an explained attempt.
