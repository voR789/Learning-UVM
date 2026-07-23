# Worked example: reusable clock observer environment

A clock agent always contains a monitor but conditionally contains a clock
driver:

```systemverilog
class clock_agent extends uvm_component;
    bit is_active;
    clock_driver driver;
    clock_monitor monitor;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = clock_monitor::type_id::create("monitor", this);
        if (is_active)
            driver = clock_driver::type_id::create("driver", this);
    endfunction
endclass
```

The owner sets `is_active` before the agent's build callback. The same agent
class can therefore generate a clock in one environment or merely observe an
externally generated clock in another.

Prediction: when `is_active == 0`, what should the driver handle contain, and
which child should still appear beneath the agent in topology?
