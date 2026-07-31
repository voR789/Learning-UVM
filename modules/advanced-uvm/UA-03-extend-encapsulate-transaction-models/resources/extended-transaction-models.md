# Extending a transaction without losing its meaning

## The observable problem

A base transaction often captures the common part of a protocol request. A
derived transaction adds data for one specialized form. For example, a normal
command may have an address and operation, while a burst command also has a
length and stride.

If the derived class copies only its new fields, the clone can retain a valid
burst shape while losing the address or operation that tells the driver what to
do. The opposite error is also possible: preserving base state but dropping the
subtype-only data.

The governing invariant is: **a copy or comparison of an extended transaction
must cover every meaningful field from every layer of its inheritance chain.**

## Encapsulation

Keep transaction state behind methods when callers should not freely assemble
an invalid request. Here the base class exposes a method for its command state,
and the derived class exposes a method for burst state. Validation is a public
question: callers can ask whether the complete transaction is usable without
depending on how it stores the fields.

This is not about hiding data for its own sake. It gives the transaction class
one authoritative place for rules such as address alignment or permitted burst
shapes.

## Worked example (separate from UA-03)

Imagine `packet` with `source` and `destination`, and `tagged_packet` that
adds `tag`.

```systemverilog
class packet extends uvm_sequence_item;
  protected int source, destination;
  virtual function void do_copy(uvm_object rhs);
    packet rhs_packet;
    if (!$cast(rhs_packet, rhs)) return;
    source = rhs_packet.source;
    destination = rhs_packet.destination;
  endfunction
endclass

class tagged_packet extends packet;
  protected int tag;
  virtual function void do_copy(uvm_object rhs);
    tagged_packet rhs_tagged;
    if (!$cast(rhs_tagged, rhs)) return;
    super.do_copy(rhs);
    tag = rhs_tagged.tag;
  endfunction
endclass
```

The derived method has two jobs: verify that the source has the expected
derived type, then delegate the common portion to `super` before handling its
own addition. Comparison follows the same layering in reverse: the base check
must pass, then the extension check must pass.

## What UA-03 asks you to decide

`ua03_cmd` validates an aligned address and legal command kind. The derived
`ua03_burst_cmd` must not replace that rule; it must add its own rule that the
length is 2, 4, or 8 beats and the stride is four bytes.

For copy and compare, ask:

1. Does the base portion still participate?
2. Is the right-hand object really the derived type before I use its added
   fields?
3. Are the burst fields handled after the base portion?

## Prediction

Suppose a burst command with a write at address `0x20` is cloned. Its clone
keeps `burst_len=4` and `byte_stride=4`, but its inherited address is left at
the default value. Would a driver receiving that clone perform the same
operation? Name the base-class action that prevents this loss.
