# Progressive hints

Use one level at a time.

## Level 1 — Diagnostic question

Which failing runs share the same earliest violated behavioral invariant, regardless of their final summary?

## Level 2 — Concept

A failure bucket represents a causal hypothesis. Report IDs and test names are observations, not causes.

## Level 3 — Location

Compare the first `DV02_DATA`, `DV02_MISSING`, or equivalent decisive line across logs, then compare the closest passing run.

## Level 4 — Pseudocode

```text
for each failing run:
    preserve test + seed + first decisive signature
    reproduce it
    compare violated invariant and triggering condition
group only when one falsifiable cause explains all members
```

## Level 5 — Minimal triage direction

Separate data-correctness violations from completion-accounting violations unless evidence shows one mechanism causally explains both.

## Level 6 — Reference answer

Reserved for an explicit request after you have submitted a populated ledger and rerun evidence.
