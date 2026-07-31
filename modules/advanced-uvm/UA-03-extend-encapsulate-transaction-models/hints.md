# UA-03 hints

## Level 1 — diagnostic question

When a burst object is copied, which fields belong to the base layer and which
belong only to the derived layer?

## Level 2 — concept

Override methods add to inherited behavior; they do not replace it unless that
is explicitly the intended contract.

## Level 3 — location

Inspect the three TODO methods in `ua03_burst_cmd`.

## Level 4 — pseudocode

For copy/compare: establish compatible derived type, handle the base portion,
then handle the burst portion.

## Level 5 — minimal repair direction

Use the supplied `rhs_burst` handle only after a successful cast. Delegate the
base work with `super` before accessing burst-only fields.

## Level 6 — reference direction

Ask for a direct code review or patch after attempting the TODOs.
