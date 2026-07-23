# TLM connections: call direction without structural coupling

UVM Transaction-Level Modeling lets one component call an interface without
knowing the concrete component on the other side.

## Port

A port is the caller's endpoint:

```systemverilog
uvm_blocking_put_port #(item_t) out;
out.put(item);
```

The port declares what operation the caller requires. It does not implement
`put()` itself.

## Imp

An implementation endpoint terminates a connection:

```systemverilog
uvm_blocking_put_imp #(item_t, sink_t) in_imp;
```

Its owner implements:

```systemverilog
task put(item_t item);
```

When the caller invokes its connected port, UVM forwards the call to this task.

## Export

An export forwards an interface toward another endpoint. A `uvm_tlm_fifo`
provides standard `put_export` and `get_export` endpoints. It owns the buffering
behavior behind them.

```text
put port → FIFO put export → queue → FIFO get export ← get port
```

## Blocking semantics

`blocking_put` may wait until the receiver can accept the item.
`blocking_get` waits until an item is available. These are tasks because they
may consume time or block.

The direction describes method calls, not physical signal direction:

- Producer calls `put()` through its put port.
- Consumer calls `get()` through its get port.
- Data enters the FIFO on put and leaves on get.

## Lifecycle

- Constructor/build: create components and their endpoint objects.
- Connect phase: connect compatible endpoints after the hierarchy exists.
- Run phase: invoke blocking transaction operations.

## Reading check

If a producer has a `put_port`, why should it not directly call a particular
consumer component's `put()` method?
