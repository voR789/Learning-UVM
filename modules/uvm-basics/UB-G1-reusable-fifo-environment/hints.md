# UB-G1 hints

## Level 1 — Diagnostic question

Which path controls the next request, and which independent path decides whether
the DUT status and data were correct?

## Level 2 — Invariant

One request produces one response and one passive observation. Responses guide
bounded stimulus; passive observations drive the independent model and checks.

## Level 3 — Location

Adaptive decisions belong in `fifo_sequence::body`, pin timing in
`fifo_driver::run_phase`, publication in `fifo_monitor::run_phase`, and expected
state in `fifo_scoreboard::write`.

## Level 4 — Reduced pseudocode

```text
issue request; receive response
while response is not at the intended boundary and guard remains:
  issue next request; receive response

at each passive observation:
  derive acceptance from pre-operation model occupancy
  update expected read data and queue
  compare all observed outputs with independent expectations
```

## Level 5 — Minimal repair direction

Repair only the failing behavioral boundary. Preserve the supplied construction,
connections, coverage, verdict, and faulty-DUT oracle.

## Level 6 — Reference direction

Compare the response-control example in the resource with the FV-G1 normative
queue algorithm. Do not use response status as the scoreboard oracle.
