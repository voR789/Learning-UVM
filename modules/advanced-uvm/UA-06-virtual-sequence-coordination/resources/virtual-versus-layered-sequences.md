# Virtual coordination versus protocol layering

## The observable problem

A block-level scenario may need several interfaces to cooperate. For example,
a control interface enables a datapath while a streaming interface waits and
then sends operands. Each interface already has its own typed sequencer and leaf
sequences. The test needs orchestration without merging those protocol APIs.

The governing invariant is: **a virtual sequence coordinates leaf sequences;
the leaf sequences still own protocol items, handshakes, and responses.**

## Virtual sequencer

A virtual sequencer is a component that holds handles to physical sequencers.
It normally drives no item type of its own:

```systemverilog
class system_virtual_sequencer extends uvm_sequencer;
  control_sequencer control_sqr;
  stream_sequencer  stream_sqr;
endclass
```

The environment creates every sequencer, then assigns the physical handles into
the virtual sequencer during `connect_phase`.

## Virtual sequence

A virtual sequence runs on that virtual sequencer and starts leaf sequences on
the appropriate physical handles. The typed `p_sequencer` macro gives the body a
safe virtual-sequencer handle:

```systemverilog
class boot_and_stream_sequence extends uvm_sequence;
  `uvm_object_utils(boot_and_stream_sequence)
  `uvm_declare_p_sequencer(system_virtual_sequencer)

  task body();
    boot_sequence boot;
    stream_sequence stream;
    boot = boot_sequence::type_id::create("boot");
    stream = stream_sequence::type_id::create("stream");
    fork
      boot.start(p_sequencer.control_sqr, this);
      stream.start(p_sequencer.stream_sqr, this);
    join
  endtask
endclass
```

The virtual sequence owns scenario order and concurrency. It does not construct
control or stream items itself.

## Why the environment wires the handles

The virtual sequence should not search the component hierarchy for sequencers.
The environment owns topology, so it explicitly links its physical sequencers
into the virtual sequencer. A missing handle is a topology/configuration failure,
not a protocol failure.

## What layered sequences mean

Layered protocol sequences solve a different problem. An upper-layer sequence
produces abstract operations, and a translation layer converts them into one or
more lower-layer protocol items. For example, a cache-line request might be
translated into several bus beats.

Use virtual sequences to coordinate *peer interfaces*. Use protocol layering to
translate *one abstraction into another*. Both may exist in a large environment,
but a virtual sequencer is not automatically a protocol translator.

Because you do not yet need a reusable upper-to-lower protocol translation in
the target project, UA-06 requires only this distinction as a reading checkpoint.

## UA-06 flow

```text
virtual sequence
  |-- control leaf -> control sequencer -> control driver
  `-- data leaf    -> data sequencer    -> data driver
```

Both leaves start concurrently. The data leaf waits on a shared enable event,
so no data item is issued until the control response is acknowledged.

## Prediction

The virtual sequence has a valid control sequencer handle but a null data
sequencer handle. Should the control driver, data leaf, or virtual coordination
layer report the topology error? Why is starting the data leaf and waiting for a
later protocol timeout weaker evidence?
