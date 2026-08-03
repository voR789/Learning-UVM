# UA-10 hints

Use one level at a time.

## Level 1 — Diagnostic question

If index 1 aliases index 0, what value will a later read of index 0 return after
the two distinct writes?

## Level 2 — Concept

Status proves completion; an independent expected value proves correctness.

## Level 3 — Location

Implement only `ua10_memory_check_seq::body()` in `tb/ua10_pkg.sv`.

## Level 4 — Pseudocode

Retain two distinct expectations, write each logical index, read each logical
index, check status and data, then account for successful comparisons.

## Level 5 — Minimal repair direction

Use the exact `uvm_mem.write()` and `uvm_mem.read()` signatures in the learning
resource. Pass the model's default map and the current sequence as parent.

## Level 6 — Reference direction

Compare your operation order and accounting with the behavioral contract in
the README. Request the complete reference implementation explicitly if still
blocked.
