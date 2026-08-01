# UA-05: Parallel hierarchical sequences

## Why this remains implementation work

UI-11 already proved sequential child-sequence composition. UB-06 and UB-G1
already proved response routing and response-driven control. UA-05 does not ask
you to repeat those mechanics.

The new invariant is lifecycle concurrency: two distinct child sequence objects
must both become active on one sequencer, each must retain its own response
ownership, and the parent must wait until both finish. The sequencer may
arbitrate their items in any legal order.

## Learn first

Read [resources/parallel-sequence-lifecycle.md](resources/parallel-sequence-lifecycle.md)
and answer its prediction before editing.

## Supplied environment

The item, sequencer, response-returning driver, child sequence, rendezvous,
environment, and test accounting are complete. Each child waits at a supplied
gate until both children are active, then issues three identified requests and
checks its own responses.

## Your work

Complete the single behavioral TODO in `ua05_parallel_sequence::body()`:

- start `first` and `second` concurrently on `m_sequencer`;
- pass the parent sequence context;
- wait for both child `start()` calls to return before the body ends.

Do not add a fixed expected global request order. Do not reuse one child object
for both branches. Do not change the supplied gate or response logic.

Run the learner test:

```powershell
cd "C:\Learning UVM\modules\advanced-uvm\UA-05-parallel-hierarchical-sequences"
.\run.ps1
```

## Fault check

Run the sequential-child fixture directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-fixture.ps1 -Test ua05_sequential_child_test
```

Expected result: nonzero exit and `UA05_CONCURRENCY`.

Run all fixtures with:

```powershell
.\tests\verify-fixtures.ps1
```

## Prediction

If the parent calls `first.start(...)` and waits for it to return before calling
`second.start(...)`, what happens when `first` reaches a rendezvous that requires
both children to be active?

## Completion

The learner run passes at seed 1 with two rendezvous arrivals, three verified
responses per child, and six driven items. The sequential fixture fails through
`UA05_CONCURRENCY`, and the reflection explains concurrency versus arbitration.
