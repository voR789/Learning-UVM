# FV-G1 Progressive hints

Use one level at a time. This integration gate intentionally provides less scaffolding than the preceding micro-modules.

## Level 1 — Diagnostic questions

- Which event makes a request accepted rather than merely attempted?
- Is your predictor consuming driver intent or passively observed facts?
- What should happen to occupancy when read and write are requested together but only one can be accepted?
- What exact condition proves every expected item has been checked before termination?

## Level 2 — Governing concepts

Model a FIFO as an independent queue updated only by accepted operations. Use pre-edge status to determine acceptance and post-edge observations to check registered state.

## Level 3 — Component boundaries

Inspect the active-edge boundary between driver and monitor, the monitor-to-scoreboard transaction fields, the reference queue update, and the process that owns timeout versus successful completion.

## Level 4 — Reduced architecture

```text
generator -> requested operation -> driver
clock edge: DUT decides acceptance from pre-edge status
monitor -> completed observation with accepted read/write and outputs
scoreboard -> independent queue update and comparisons
coverage -> sample the completed observation once
completion -> required scenarios covered and all expected reads checked
```

## Level 5 — Minimal repair direction

After you show a failing log or code attempt, request review of one boundary: acceptance, sampling edge, queue update, assertion, coverage hole, or termination.

## Level 6 — Reference solution

Available only after an explicit request and an explained implementation attempt. Seeded DUT defect locations remain undisclosed until you produce diagnostic evidence.
