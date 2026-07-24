# UI-08 progressive hints

Use only one level per coaching turn.

## Level 1 — diagnostic question

At the final count check, which number distinguishes “the monitor never
published” from “one branch of the broadcast was never connected”?

## Level 2 — concept or invariant

An analysis port is a one-to-many publisher. Every required receiver needs its
own connection, while the publisher makes only one `write()` call.

## Level 3 — location

Inspect endpoint declaration/construction in `ui08_monitor`, then routing in
`ui08_env::connect_phase`. The subscriber endpoint is inherited; the audit
endpoint is explicitly declared.

## Level 4 — pseudocode

```text
publisher owns typed analysis_port
constructor creates port
runtime: port.write(observation)
connect_phase:
  port -> subscriber endpoint
  same port -> audit endpoint
```

## Level 5 — minimal repair direction

Repair only the absent declaration, constructor assignment, publication call,
or missing connection identified by the counts. Do not alter consumer checks.

## Level 6 — reference solution

Available only after an explicit request and a reviewed attempt. Compare the
typed port and two fan-out connections with the differently named temperature
example, then adapt the types and instance handles to this worksheet.
