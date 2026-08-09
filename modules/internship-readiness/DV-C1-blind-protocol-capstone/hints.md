# DV-C1 progressive hints

Stop at the first level that gets you moving.

## Level 1 — diagnostic question

Which clock-edge events create and retire one scoreboard obligation?

## Level 2 — invariant

Only accepted commands create obligations; only transferred responses retire
them. Response stalls change neither.

## Level 3 — boundary

Inspect the passive command and response monitor publications and the structure
that retains outstanding expectations across those two streams.

## Level 4 — pseudocode

On accepted command: independently predict and store an expectation keyed by the
protocol identity. On transferred response: locate the obligation, check all
fields and ordering, then retire it. On reset: discard pre-reset obligations.

## Level 5 — minimal repair direction

Repair only the boundary that loses, duplicates, or prematurely retires an
obligation. Keep driver activity out of the scoreboard's observed-event count.

## Level 6 — reference direction

Request an explicit architecture review. No complete capstone solution is stored
in this module.
