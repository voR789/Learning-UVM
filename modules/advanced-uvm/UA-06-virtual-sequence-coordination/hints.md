# UA-06 hints

## Level 1 — diagnostic question

Which component owns all three sequencer handles and therefore has enough
topology knowledge to link the physical handles into the virtual one?

## Level 2 — concept

The environment wires topology; the virtual sequence orchestrates leaf
lifecycle on the handles it receives through `p_sequencer`.

## Level 3 — location

Inspect `ua06_env::connect_phase()` and `ua06_virtual_sequence::body()`.

## Level 4 — pseudocode

Environment: assign control and data sequencer handles. Virtual sequence: start
one leaf per matching handle concurrently, then wait for both.

## Level 5 — minimal repair direction

Use the supplied `virtual_sequencer`, `p_sequencer`, leaf handles, and parent
context. Do not add hierarchy lookups or driver calls.

## Level 6 — reference direction

Ask for direct syntax after attempting both TODO regions.
