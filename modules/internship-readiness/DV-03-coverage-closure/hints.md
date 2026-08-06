# Progressive hints

Use one level at a time.

## Level 1 — Diagnostic question

Which uncovered scenario IDs correspond to required rows in the specification?

## Level 2 — Concept

Reachable required holes need stimulus; prohibited combinations need specification-backed disposition.

## Level 3 — Location

Compare `DV03_HOLE` IDs with the six-row scenario table, then change only the target sequence.

## Level 4 — Pseudocode

```text
for each uncovered candidate:
    if required and legal:
        publish one targeted observation
    else if prohibited by specification:
        document the exclusion
```

## Level 5 — Minimal repair direction

Add one legal target for each missing required scenario. Do not add any other observations or change coverage internals.

## Level 6 — Reference answer

Reserved for an explicit request after an attempted disposition and targeted sequence.
