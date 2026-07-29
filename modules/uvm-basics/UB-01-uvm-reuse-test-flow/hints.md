# UB-01 hints

## Level 1: Diagnostic question

Which responsibility creates contention if duplicated, and which responsibility
is useful regardless of who drives?

## Level 2: Concept

Separate active stimulus mechanism from passive observation mechanism.

## Level 3: Location

Compare the two test configurations with the conditional child construction in
the supplied agent.

## Level 4: Pseudocode

```text
test selects mode
environment creates agent
agent always creates observer
agent conditionally creates active endpoint
test checks resulting topology
```

## Level 5: Minimal repair direction

Correct only the ownership decision that contradicts the one-driver invariant,
then revisit which components remain reusable.

## Level 6: Reference direction

Describe the block context as active and the subsystem context as passive;
retain monitoring/checking in both, and keep configuration in the test,
structure in components, connections in `connect_phase`, and timed work in
`run_phase`.
