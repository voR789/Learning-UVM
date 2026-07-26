# UI-G1 progressive hints

Use one level per learner turn and debug one boundary at a time.

## Level 1 — diagnostic question

Which first count diverges: driven, observed, checked, or sampled?

## Level 2 — concept

Stimulus intent and authoritative observation are different streams. Prediction
must consume the passive observed stream.

## Level 3 — location

Inspect the boundary immediately before the first divergent count: driver edge,
monitor sample timing, analysis connection, or subscriber `write()`.

## Level 4 — pseudocode

```text
sequence -> driver command edge
monitor waits through DUT update -> publishes
scoreboard predicts from command -> compares observed count
coverage samples same observation
test requires all counts and reports to agree
```

## Level 5 — minimal repair

Repair only the first broken boundary; rerun the same seed and preserve the
fault oracle.

## Level 6 — reference solution

Available only after an explicit request following a reviewed attempt.
