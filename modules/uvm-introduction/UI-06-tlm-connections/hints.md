# UI-06 Progressive Hints

## Level 1

For each caller port, which component owns the intended receiving operation:
FIFO storage, FIFO retrieval, or audit checking?

## Level 2

Ports initiate calls, exports forward interfaces, and imps terminate calls in
an owner's implementation method.

## Level 3

All three TODOs are in `ui06_env::connect_phase`; do not modify run phases.

## Level 4

```text
producer item put port → FIFO put export
consumer get port → FIFO get export
producer audit put port → audit put imp
```

## Level 5

Call `.connect(destination_endpoint)` on each caller port using the matching
typed endpoint from the diagram.

## Level 6

Connect `producer.item_out` to `fifo.put_export`, `consumer.item_in` to
`fifo.get_export`, and `producer.audit_out` to `audit.in_imp`.
