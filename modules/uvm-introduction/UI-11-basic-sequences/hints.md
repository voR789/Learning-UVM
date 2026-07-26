# UI-11 progressive hints

Use one level per coaching turn.

## Level 1 — diagnostic question

Is the blocked process waiting for a child sequence to return, for the driver to
acknowledge an item, or for an item that was never generated?

## Level 2 — concept or invariant

The composite owns subsequence order; each leaf owns its item handshake; the
driver acknowledges every accepted request exactly once.

## Level 3 — location

Leaf item generation is in `ui11_burst_sequence::body`; composition is in
`ui11_composite_sequence::body`; terminal request completion is in the driver.

## Level 4 — pseudocode

```text
leaf: loop -> create -> start_item -> assign -> finish_item
composite: create/config/start first; create/config/start second
driver: repeat six -> get -> check -> count -> item_done
test: start composite -> reduce completion/report evidence
```

## Level 5 — minimal repair direction

Repair only the first incomplete handshake or missing child shown by the
timeout/order evidence. Do not add convenience macros or relax counts.

## Level 6 — reference solution

Available only after an explicit request following a reviewed attempt. Adapt
the separate register example's composition pattern to UI-11's distinct item
fields and six-item contract.
