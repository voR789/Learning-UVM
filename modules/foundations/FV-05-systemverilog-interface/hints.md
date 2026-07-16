# FV-05 Progressive hints

## Level 1 — Diagnostic question

From whose perspective is each modport direction declared?

## Level 2 — Concept

A virtual interface is a handle to an existing interface instance; it does not create signals.

## Level 3 — Location

The module creates `bus`; the class constructor receives the handle; `check_case` owns drive/wait/sample behavior.

## Level 4 — Pseudocode

```text
construct checker(bus)
checker drives vif inputs
checker waits for combinational settling
checker samples vif outputs
checker counts mismatches
```

## Level 5 — Minimal repair direction

Ask for review of one attempted modport or virtual-interface operation.

## Level 6 — Reference solution

Available only after an explicit request and an explained attempt.
