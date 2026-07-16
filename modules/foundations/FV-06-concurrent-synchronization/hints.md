# FV-06 Progressive hints

## Level 1 — Diagnostic question

Which process is authoritative for deciding that all generated work has actually been checked?

## Level 2 — Concept

Mailbox `get()` blocks until data exists. Events announce state transitions but do not store transaction data.

## Level 3 — Location

Use `reset_done` to release the driver and `checking_done` to release final termination. The scoreboard owns the latter.

## Level 4 — Pseudocode

```text
generator: create -> expected calculation -> gen_to_drv.put
driver: wait reset -> gen_to_drv.get -> drive -> exp_to_sb.put(copy)
monitor: sample accepted output -> mon_to_sb.put(fresh observation)
scoreboard: exp_to_sb.get + mon_to_sb.get -> compare -> signal done
```

## Level 5 — Minimal repair direction

Ask for review of one process and its synchronization boundary.

## Level 6 — Reference solution

Available only after an explicit request and an explained attempt.
