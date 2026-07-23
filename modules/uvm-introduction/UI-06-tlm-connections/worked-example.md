# Worked example: command source and logger

```systemverilog
class logger extends uvm_component;
    `uvm_component_utils(logger)
    uvm_blocking_put_imp #(command, logger) command_in;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        command_in = new("command_in", this);
    endfunction

    task put(command cmd);
        `uvm_info("LOGGER", cmd.convert2string(), UVM_LOW)
    endtask
endclass

class source extends uvm_component;
    `uvm_component_utils(source)
    uvm_blocking_put_port #(command) command_out;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        command_out = new("command_out", this);
    endfunction
endclass
```

An environment connects them:

```systemverilog
source_h.command_out.connect(logger_h.command_in);
```

The source remains coupled only to the typed blocking-put contract. Another
compatible sink can replace the logger without changing the source.

Prediction: after connection, when the source executes
`command_out.put(cmd)`, which class's task body runs?
