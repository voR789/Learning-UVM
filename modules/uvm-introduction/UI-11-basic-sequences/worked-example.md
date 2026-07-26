# Worked example: composing register-operation sequences

This example uses different transaction fields and counts.

```systemverilog
class register_burst extends uvm_sequence #(register_item);
  `uvm_object_utils(register_burst)
  int first_address;
  bit write_kind;

  task body();
    register_item req;
    for (int i = 0; i < 2; i++) begin
      req = register_item::type_id::create($sformatf("req_%0d", i));
      start_item(req);
      req.address = first_address + i;
      req.write_kind = write_kind;
      finish_item(req);
    end
  endtask
endclass

class setup_then_read extends uvm_sequence #(register_item);
  `uvm_object_utils(setup_then_read)

  task body();
    register_burst setup;
    register_burst readback;

    setup = register_burst::type_id::create("setup");
    setup.first_address = 16;
    setup.write_kind = 1;
    setup.start(m_sequencer, this);

    readback = register_burst::type_id::create("readback");
    readback.first_address = 16;
    readback.write_kind = 0;
    readback.start(m_sequencer, this);
  endtask
endclass
```

The composite decides “setup then readback.” The leaf provides the reusable
two-item burst and item handshake.
