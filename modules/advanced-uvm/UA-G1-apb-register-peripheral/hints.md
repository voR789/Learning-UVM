# UA-G1 hints

Use one level at a time.

## Level 1 — diagnostic question

Which component first turns a completed APB access into a transaction that all
three passive consumers can trust?

## Level 2 — invariant

Predict errors from pre-transfer scoreboard state, and update modeled register
state only after a successful observed write.

## Level 3 — location

Inspect the four TODO regions in `tb/ua_g1_pkg.sv`: monitor `run_phase`,
scoreboard `write`, coverage `write`, and scenario `body`.

## Level 4 — reduced flow

```text
wait for completed access
  -> publish observation
  -> predict expected error from old model state
  -> if accepted write, update model
  -> if accepted result read, compare and account
```

For the scenario:

```text
rejected command
configure
submit normal command
bounded poll
read/check result
submit saturating command
bounded poll
read/check result
```

## Level 5 — minimal repair direction

Split each scoreboard transfer into three decisions: expected response,
accepted state update, and readback check. Keep each result check separately
accounted. In the sequence, check every RAL status before consuming returned
data.

## Level 6 — reference direction

Request an explicit reference only after showing the failing trace and your
current implementation. The reference must preserve monitor-only scoreboard and
coverage inputs, bounded polling, per-result accounting, and drain-based test
completion.
