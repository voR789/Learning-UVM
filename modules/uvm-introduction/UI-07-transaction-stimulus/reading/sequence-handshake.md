# Sequence, sequencer, and driver: policy, arbitration, execution

## Roles

- **Sequence item:** one request's data.
- **Sequence:** creates and orders request items.
- **Sequencer:** arbitrates and coordinates request ownership.
- **Driver:** receives one granted request and performs its timed execution.

The sequencer does not invent stimulus and does not drive pins. It mediates the
handshake between sequences and the driver.

## Sequence-side handshake

```systemverilog
req = item_type::type_id::create("req");
start_item(req);
req.id = ...;
req.payload = ...;
finish_item(req);
```

`start_item` requests/grants permission to prepare the next item. Fields are
set after the grant. `finish_item` sends the prepared item and waits for the
driver-side completion handshake.

## Driver-side handshake

```systemverilog
seq_item_port.get_next_item(req);
// Execute/check the request.
seq_item_port.item_done();
```

`get_next_item` blocks until a granted item is available. The driver must call
`item_done` exactly once after it has finished using that request.

## TLM reinforcement

The driver owns a caller port and the sequencer provides the matching export:

```systemverilog
driver.seq_item_port.connect(sequencer.seq_item_export);
```

As in UI-06, components declare endpoints and the agent connects them during
`connect_phase`. The specialized sequence-item interface carries request
handshake operations rather than generic FIFO put/get calls.

## Why item_done matters

Without `item_done`, the sequence believes the request is still owned by the
driver. It cannot safely complete that item and proceed normally. A missing
completion response therefore causes a reproducible deadlock rather than a
false pass.

## Reading check

Which role chooses the next payload, which role arbitrates access, and which
role owns the request until `item_done()`?
