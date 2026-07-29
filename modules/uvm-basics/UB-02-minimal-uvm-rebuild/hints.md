# UB-02 Hints

## Level 1 — Diagnostic question

Which phase owns hierarchy construction, and which component should decide when
this test is allowed to end?

## Level 2 — Invariant

Components exist before runtime work begins; runtime work may execute
concurrently; one clear test-level policy keeps the test alive until its
observable completion condition.

## Level 3 — Location

Inspect the two constructors, the test's `build_phase`, and both `run_phase`
methods. Each has one distinct lifecycle responsibility.

## Level 4 — Reduced pseudocode

```text
build:
  perform inherited build behavior
  factory-create child beneath this test

test runtime:
  keep test alive
  wait for the worker's completion state
  verify hierarchy and count
  release test
```

## Level 5 — Minimal repair direction

Confirm both classes are registered, both constructors delegate to their parent
class, and the factory creation call receives the test as parent. Guard class
handles with explicit `if/else` before dereferencing them in XSim.

## Level 6 — Reference direction

Compare the lifecycle shape with the completed UI-G1 test and environment:
registration enables type lookup, `build_phase` creates structure, concurrent
`run_phase` tasks do timed work, and the test owns the objection surrounding its
completion check.
