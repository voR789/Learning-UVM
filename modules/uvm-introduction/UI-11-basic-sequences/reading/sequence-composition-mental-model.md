# Sequence composition mental model

## The three layers of intent

Sequence composition separates stimulus into three levels:

```text
test
  chooses when and where the scenario runs
    |
    v
composite sequence
  chooses which reusable behaviors run and in what order
    |
    v
leaf sequence
  creates/configures individual items and performs their handshakes
```

The driver is outside this policy stack. It accepts whichever item the
sequencer grants and translates that transaction into execution or checking.

## Separate reusable behavior from scenario policy

A leaf sequence implements one reusable behavior, such as a burst. Public
fields configure that behavior before it starts. A composite sequence creates
leaf sequences, sets those fields, and starts them in the scenario's intended
order.

This separation lets the same leaf participate in multiple scenarios. Changing
its starting values or item count changes configuration; it does not require
another copy of the handshake loop.

## Nested start

The test starts the composite on a sequencer. Inside its `body()`, the composite
starts each child on `m_sequencer` and supplies itself as the parent sequence.
The child's `start()` call returns only after that child finishes.

Sequential child `start()` calls therefore create deterministic ordering. This
is composition, not concatenating item arrays.

The runtime call stack is conceptually:

```text
test: composite.start(sequencer)
  composite.body()
    first_child.start(m_sequencer, composite)
      first_child.body()
        item handshakes
      return to composite
    second_child.start(m_sequencer, composite)
      second_child.body()
        item handshakes
      return to composite
  return to test
```

The first child call blocks until that child returns, so the second child cannot
begin early. Parallel children would require explicit concurrency and would
introduce arbitration between active sequences; that is outside this exercise.

## What `m_sequencer` and the parent preserve

When the test starts the composite, UVM records the sequencer on which it is
running. The composite refers to that current sequencer through `m_sequencer`.
Passing it to a child routes the child's item requests through the same
sequencer and therefore to the same connected driver.

Supplying `this` as the parent records that the child belongs to the composite's
sequence context. This preserves UVM's nesting relationship for sequence
context, reporting, and arbitration information.

Neither argument creates an item or connects the driver. The environment still
owns the driver's port-to-export connection.

## Handshake ownership

For every item:

```text
leaf                            driver
 |                                |
 |-- start_item(req)               |
 |   wait for sequencer grant      |
 |                                |
 |   assign granted item fields    |
 |                                |
 |-- finish_item(req)              |
 |                         get_next_item()
 |                         consume/check
 |                         item_done()
 |<-- finish_item returns ---------|
```

The composite does not replace this handshake. It reuses a leaf that owns it.

Important blocking points:

- `start_item()` can wait for sequencer arbitration.
- `finish_item()` can wait for the driver's acknowledgment.
- `get_next_item()` waits when no sequence has supplied another item.
- A child `start()` waits for the entire child `body()` to return.

These waits form a dependency chain. A missing item, acknowledgment, or child
can stall a different layer, so identifying the blocked call is useful
debugging evidence.

## Completion

The composite returning proves its children returned, but the test should still
check driver-owned completion evidence. An objection keeps runtime alive while
the composite executes; a timeout catches a child omission or missing
acknowledgment.

There are two complementary completion claims:

```text
subsequence count = scenario policy completed both intended children
driver count      = terminal consumer accepted and acknowledged all items
```

Neither count alone proves the whole scenario. The final verdict checks both.

## Applying the model to the fault fixture

If the composite omits its second child, the first child still completes and
the composite can return. The driver, however, continues its six-item contract.
After consuming the three available items, its next `get_next_item()` has no
request to return, so it remains blocked. The top-level timeout exposes the
disagreement between scenario generation and terminal completion.
