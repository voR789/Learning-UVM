# UB-04 Hints

## Level 1 — Diagnostic question

Which child exists in both modes, and which two handles are valid only in active
mode?

## Level 2 — Invariant

Passive reuse preserves observation while removing every driving owner.

## Level 3 — Location

Mode-dependent ownership belongs in the agent's `build_phase`; the corresponding
request connection belongs in `connect_phase`.

## Level 4 — Reduced pseudocode

```text
build monitor
if active:
  build sequencer
  build driver

connect:
  if active:
    connect request path
```

## Level 5 — Minimal repair direction

Call inherited phase behavior, inspect the agent's configured active/passive
state, and never dereference active-only handles outside the active branch.

## Level 6 — Reference direction

Compare responsibility boundaries with the UI-G1 agent, then add the
configuration-dependent construction learned in UB-01. Do not copy unrelated
scoreboard, coverage, or DUT wiring.
