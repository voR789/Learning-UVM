# Progressive hints

Use one level only, then rerun or gather evidence before continuing.

## Level 1 — Diagnostic question

Do the two `DV01_CHECK` records show distinct object identities, and how does that compare with the two `DV01_PUBLISH` records?

## Level 2 — Concept

UVM analysis transport passes class handles. A FIFO retains the handle; it does not automatically preserve the object's field values at write time.

## Level 3 — Location

Inspect the boundary that creates and publishes completed observations. Ask whether every published observation remains stable after `write`.

## Level 4 — Pseudocode

```text
for each completed observation:
    obtain an object whose lifetime belongs to this observation
    fill its fields
    publish it
    do not mutate that published snapshot
```

## Level 5 — Minimal repair direction

Change only the publisher's observation ownership policy so each publication has stable identity/state. Leave FIFO and scoreboard behavior intact.

## Level 6 — Reference answer

Reserved for an explicit request after an attempted diagnosis. Compare your repair with `tests/reference_pkg.sv` only after assessment coaching authorizes it.
