# TLM from first principles: moving transactions between components

## 1. The problem before UVM terminology

Assume a producer creates this transaction:

```systemverilog
ui06_item item;
item.id      = 7;
item.payload = 42;
```

The producer needs to send it to another component. The simplest ordinary OOP
approach would be to store a handle to one concrete consumer:

```systemverilog
ui06_consumer consumer;
consumer.receive(item);
```

This works, but it tightly couples the producer to `ui06_consumer`:

- The producer must know that exact consumer class.
- The producer must know the consumer's method name.
- Replacing the consumer requires editing the producer.
- Inserting a FIFO requires editing the producer.
- Sending the item to a different compatible receiver requires another
  concrete handle and another method call.

The producer's real requirement is smaller:

> “I need somewhere that supports a blocking `put(item)` operation.”

UVM TLM lets the producer depend on that operation contract instead of a
particular receiving component.

TLM means **Transaction-Level Modeling**. Here, “transaction-level” means that
components exchange class objects such as `ui06_item` rather than directly
sharing DUT pins.

## 2. The telephone analogy

Think of a TLM connection like a telephone system:

- A **port** is the caller's telephone.
- An **imp** is the person who ultimately answers and performs the work.
- An **export** forwards the call through an intermediate service.
- `connect()` establishes the route before calls begin.

The caller does not need a direct handle to the person answering. It only needs
a compatible telephone endpoint.

```text
caller component
    |
    | calls put(item)
    v
put port ───────── connection ───────── put imp
                                           |
                                           v
                              receiver's put() task executes
```

The port does not contain the final implementation. It forwards the operation
through the connection UVM established.

## 3. Port: the endpoint that initiates an operation

The producer declares:

```systemverilog
uvm_blocking_put_port #(ui06_item) item_out;
```

Break down the type:

```text
uvm_blocking_put_port
│   │        │
│   │        └── endpoint used by the caller
│   └─────────── operation may block
└─────────────── operation is put

#(ui06_item)
└── only ui06_item transactions may use this connection
```

The producer constructs the port endpoint in its constructor:

```systemverilog
function new(string name, uvm_component parent);
    super.new(name, parent);
    item_out = new("item_out", this);
endfunction
```

This creates the endpoint object. It does not connect the endpoint to a
receiver yet.

During `run_phase`, the producer can call:

```systemverilog
item_out.put(item);
```

Read that as:

> “Invoke the blocking-put operation through whatever compatible endpoint the
> environment connected to `item_out`.”

The producer does not need to know whether the receiver is:

- a FIFO;
- an audit component;
- a driver;
- a scoreboard adapter;
- or another compatible TLM service.

### What a port owns

A port owns the caller-facing access point and the required interface type.

### What a port does not own

A port does not decide what receiving component should do with the item. It
does not automatically store, copy, compare, or broadcast the transaction.

## 4. Imp: the endpoint where an operation is implemented

`imp` is short for **implementation**.

The UI-06 audit sink declares:

```systemverilog
uvm_blocking_put_imp #(ui06_item, ui06_audit_sink) in_imp;
```

The parameters say:

```text
ui06_item
    Transaction type accepted by this endpoint.

ui06_audit_sink
    Component class that implements the put() task.
```

The sink constructs the endpoint:

```systemverilog
function new(string name, uvm_component parent);
    super.new(name, parent);
    in_imp = new("in_imp", this);
endfunction
```

The sink then supplies the actual method body:

```systemverilog
task put(ui06_item item);
    // Check or process the item here.
endtask
```

After the environment connects the producer's port to this imp:

```systemverilog
producer.audit_out.connect(audit.in_imp);
```

this producer call:

```systemverilog
producer.audit_out.put(item);
```

ultimately executes:

```systemverilog
ui06_audit_sink::put(item)
```

The key division is:

```text
port:
    “I need to call put.”

imp:
    “I provide the implementation of put.”
```

## 5. Export: an endpoint that forwards an interface

An export is not the original caller and is not necessarily the final
component-written implementation. It makes an interface supplied behind it
available to something connected in front of it.

Think of it as a forwarding doorway:

```text
port → export → service behind the export
```

UI-06 uses exports supplied by `uvm_tlm_fifo`:

```systemverilog
fifo.put_export
fifo.get_export
```

The FIFO already contains the implementation needed to store and retrieve
transactions. Its exports expose those operations to other components.

The environment connects:

```systemverilog
producer.item_out.connect(fifo.put_export);
consumer.item_in.connect(fifo.get_export);
```

The producer and consumer do not call methods on the concrete FIFO handle.
They call through their own ports, which are connected to the FIFO's exported
interfaces.

## 6. The FIFO has two sides

A FIFO needs two different operation contracts:

```text
put side:
    accepts and stores an item

get side:
    removes and returns an item
```

That produces this structure:

```text
producer                                      consumer
item_out                                      item_in
(put port)                                    (get port)
    |                                             |
    | put(item)                                   | get(item)
    v                                             v
fifo.put_export  →  internal queue  →  fifo.get_export
```

The producer performs:

```systemverilog
item_out.put(item);
```

Because `item_out` is connected to `fifo.put_export`, the FIFO stores the item.

The consumer performs:

```systemverilog
item_in.get(item);
```

Because `item_in` is connected to `fifo.get_export`, the FIFO removes an item
and assigns its handle into the consumer's `item` variable.

### Why the arrows can feel confusing

There are two relationships:

1. **Method-call direction**
2. **Transaction-data movement**

For the get side, the consumer initiates the method call:

```text
consumer get port calls toward FIFO get export
```

but the returned item moves from FIFO to consumer:

```text
FIFO supplies transaction data to consumer
```

So do not interpret a TLM port name as a physical wire direction. Ask:

- Who calls the operation?
- Who provides the implementation?
- Where does the transaction data move?

## 7. Blocking means the call may wait

UI-06 uses:

```systemverilog
uvm_blocking_put_port
uvm_blocking_get_port
```

These operations are tasks because they may block.

### Blocking get

If the consumer calls:

```systemverilog
item_in.get(item);
```

while the FIFO is empty, the consumer waits until an item becomes available.
It does not receive a fake item and does not need to poll repeatedly.

```text
consumer calls get
        ↓
FIFO empty
        ↓
consumer task waits
        ↓
producer puts item
        ↓
get completes with item
```

### Blocking put

If a bounded FIFO is full, a blocking put may wait until space becomes
available.

UI-06 uses a depth-one FIFO:

```systemverilog
fifo = new("fifo", this, 1);
```

It can store one item. A second `put()` can block until the first item is
removed.

This behavior is important in the deliberate misroute fault:

- The normal item goes into the FIFO.
- The audit output is incorrectly connected to the same FIFO.
- The audit sink never receives a call.
- Completion cannot be proven.
- The test times out instead of reporting a false pass.

## 8. Why connections belong in connect_phase

The endpoint objects must exist before they can be connected.

Construction occurs first:

```text
build hierarchy
    producer creates ports
    consumer creates get port
    audit creates imp
    environment creates FIFO
```

Then UVM calls `connect_phase`, where the environment establishes routes:

```systemverilog
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    producer.item_out.connect(fifo.put_export);
    consumer.item_in.connect(fifo.get_export);
    producer.audit_out.connect(audit.in_imp);
endfunction
```

Only after structure and connections are established does `run_phase` begin
moving transactions.

```text
build_phase:
    create components and endpoint objects

connect_phase:
    establish endpoint-to-endpoint routes

run_phase:
    call put/get and move transactions
```

Connecting in `run_phase` would be late and could race with components already
trying to use their ports.

## 9. The two UI-06 paths, traced completely

The producer creates one object:

```text
ui06_item
id      = 7
payload = 42
```

### Buffered consumer path

```text
1. producer calls item_out.put(item)
2. item_out is connected to fifo.put_export
3. FIFO stores the item handle
4. consumer calls item_in.get(item)
5. item_in is connected to fifo.get_export
6. FIFO removes and returns the stored handle
7. consumer checks id and payload
8. consumer increments checks
```

### Direct audit path

```text
1. producer calls audit_out.put(item)
2. audit_out is connected to audit.in_imp
3. the imp routes the call to ui06_audit_sink::put()
4. audit checks id and payload
5. audit increments checks
```

The same transaction handle is sent on both paths. Neither receiver mutates it,
so sharing that handle is safe in this bounded example. Later designs may copy
transactions when ownership or mutation rules require independent objects.

## 10. Why not directly call the consumer?

Without TLM:

```systemverilog
producer.consumer_h.receive(item);
```

The producer depends on:

- the concrete consumer class;
- its handle;
- its method name;
- and its placement in the hierarchy.

With TLM:

```systemverilog
producer.item_out.put(item);
```

The producer depends only on:

```text
blocking put of ui06_item
```

The environment decides what compatible endpoint fulfills that contract.

That allows the environment to change routing without rewriting producer
behavior:

```text
producer → FIFO
producer → driver
producer → adapter
producer → compatible terminal imp
```

The producer still calls the same typed port operation.

## 11. Port, export, and imp in one table

| Endpoint | Primary role | Contains final component method body? | UI-06 example |
|---|---|---:|---|
| Port | Initiates a required operation | No | `producer.item_out`, `consumer.item_in` |
| Export | Forwards/exposes an interface implemented behind it | Not necessarily | `fifo.put_export`, `fifo.get_export` |
| Imp | Terminates the connection at an owner's implementation | Yes | `audit.in_imp` routes to `audit.put()` |

## 12. What TLM does not do automatically

A connection does not automatically:

- create transactions;
- copy transaction objects;
- check correctness;
- broadcast one call to multiple destinations;
- end the test;
- prevent deadlock;
- determine whether a receiver is architecturally appropriate.

Those remain verification-design responsibilities.

UI-06 explicitly adds:

- producer item creation;
- consumer and audit checking;
- a FIFO;
- destination counts;
- and a completion barrier.

## Reading check

The producer executes:

```systemverilog
producer.audit_out.put(item);
```

Given this connection:

```systemverilog
producer.audit_out.connect(audit.in_imp);
```

which endpoint initiates the operation, which class contains the task body that
actually executes, and why can the producer remain unaware of that concrete
class?
