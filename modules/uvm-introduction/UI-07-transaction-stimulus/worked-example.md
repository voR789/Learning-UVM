# Worked example: one reset command

```systemverilog
task body();
    reset_item req;
    req = reset_item::type_id::create("req");
    start_item(req);
    req.assert_cycles = 4;
    finish_item(req);
endtask
```

Driver:

```systemverilog
seq_item_port.get_next_item(req);
// Assert reset for req.assert_cycles.
seq_item_port.item_done();
```

Agent connection:

```systemverilog
driver.seq_item_port.connect(sequencer.seq_item_export);
```

Prediction: does `start_item()` itself send a fully prepared reset request to
the driver, or does it first obtain permission for the sequence to prepare one?
