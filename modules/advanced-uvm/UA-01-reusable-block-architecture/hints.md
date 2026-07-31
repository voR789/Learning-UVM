# UA-01 hints

UA-01 is read-only; use these only if the boundary prediction is unclear.

## Level 1 — Diagnostic question

Which class would you have to duplicate if active/passive policy were embedded
in the environment implementation?

## Level 2 — Concept

Separate structural policy from reusable structure.

## Level 3 — Location

Compare the UI-05 configuration object, environment, and agent build decisions.

## Level 4 — Reduced flow

```text
test chooses policy
configuration carries policy
environment distributes policy
agent builds the matching topology
```

## Level 5 — Minimal direction

Keep the agent and environment classes unchanged; vary the per-instance
configuration supplied before their dependent children build.

## Level 6 — Reference answer

The configuration object should vary. The same environment and agent classes
consume different per-instance policy.
