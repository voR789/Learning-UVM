# FV-03 Progressive hints

## Level 1 — Diagnostic question

After `second = first`, how many objects were constructed?

## Level 2 — Concept

Class assignment copies a handle; it does not clone the object. Struct assignment copies the struct value.

## Level 3 — Location

Inspect the alias experiment separately from `copy_from`; they are intended to demonstrate opposite ownership behavior.

## Level 4 — Pseudocode

```text
alias = original
change alias.field
check original.field

copy = new
copy.copy_from(original)
change copy.field
check original.field did not change
```

## Level 5 — Minimal repair direction

Ask for a focused review of one attempted method or experiment.

## Level 6 — Reference solution

Available only after an explicit request and an explained attempt.
