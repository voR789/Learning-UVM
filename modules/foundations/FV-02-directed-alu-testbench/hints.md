# FV-02 Progressive hints

## Level 1 — Diagnostic question

What incorrect DUT output could currently occur without changing `error_count`?

## Level 2 — Concept

A self-checking test must drive, wait, observe, compare, report, and count failures.

## Level 3 — Location

Implement those responsibilities inside `check_case`; keep the `initial` block focused on case data and final termination.

## Level 4 — Pseudocode

```text
drive inputs
wait for settling
increment checks
if any actual output differs from its expected value
    print the case and both value sets
    increment errors
```

## Level 5 — Minimal repair direction

Ask for a focused review of your attempted `check_case` task.

## Level 6 — Reference solution

Available only after an explicit request and an explained attempt.
