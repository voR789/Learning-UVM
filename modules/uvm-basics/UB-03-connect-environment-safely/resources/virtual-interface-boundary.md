# Virtual interface boundary

## Problem

Class-based UVM components cannot directly contain or connect module/interface
instances, but drivers and monitors still need signal access.

## Mental model

The static testbench top owns the real interface instance. It deposits a virtual
handle in `uvm_config_db`. A component retrieves that handle during
`build_phase` and uses it during timed phases.

Think of config_db as delivering a reference, not copying the interface:

```text
tb_top physical interface -> config_db handle -> driver/monitor virtual handle
```

## Worked example

For an unrelated UART interface, the top may set a `virtual uart_if` for an
environment subtree. A UART monitor retrieves it during build and fatals if the
required handle is missing. The monitor then samples through that handle without
knowing the physical instance name.

## Invariant

Exactly one static interface instance owns the signals; every UVM component that
needs those signals receives a valid handle before runtime work begins.

## Prediction

If the config_db path does not include the monitor, what should fail first:
compilation, build-time configuration, or signal sampling much later?

- If the config_db path does not include the monitor, only signal sampling will fail, because the monitor will think the virtual handle points to the dut interface the whole time, but it will point to nothing. The correct design policy would be to catch this at build time.
