# Parallel child-sequence lifecycle

## The observable problem

A hierarchical sequence often coordinates multiple reusable child sequences.
Calling one child's `start()` and then the other's is sequential: the first
`start()` blocks until that child finishes. To make both children active at the
same time, their blocking `start()` calls must execute in separate processes.

The governing invariant is: **parallel children require distinct sequence
objects, concurrent `start()` calls, and a parent that does not finish until all
children finish.**

## What the sequencer still controls

Both children may target the same sequencer. That does not mean the driver
receives two items simultaneously. The sequencer arbitrates between requests
and grants one item at a time to the driver.

Concurrency describes active sequence lifecycles. Arbitration describes which
waiting sequence gets the next item grant. A test should verify each child's
local order and completion, not accidentally require one simulator's global
interleaving unless the specification demands it.

## Worked example: two register traffic streams

```systemverilog
task body();
  status_sequence status;
  control_sequence control;

  status = status_sequence::type_id::create("status");
  control = control_sequence::type_id::create("control");

  fork
    status.start(m_sequencer, this);
    control.start(m_sequencer, this);
  join
endtask
```

`fork...join` starts both blocking calls concurrently and waits for both. Passing
`this` preserves the hierarchical parent relationship. Because the objects are
distinct, each has its own sequence identity, state, and response queue.

## Why not reuse one sequence handle?

A sequence object has live lifecycle state. Starting the same object in two
branches creates conflicting ownership of that state and is not a valid way to
represent two independent traffic streams. Create one object per concurrent
activity.

## Response ownership

The driver copies request routing identity into each response with
`set_id_info()`. The sequencer then routes the response back to the child that
issued the request. Parallelism does not justify reading another child's
responses or sending predictor data into the sequencer.

## UA-05 rendezvous

The supplied child sequence calls a gate before issuing items. The first child
waits until the second child arrives. If the parent starts children sequentially,
the first child cannot finish, so the parent never reaches the second `start()`
until the gate reports `UA05_CONCURRENCY` and releases the test.

## Prediction

Both children are active and each requests an item. Must the driver see a fixed
alternating pattern such as A0, B0, A1, B1? What properties remain safe to check
regardless of the sequencer's legal arbitration order?
