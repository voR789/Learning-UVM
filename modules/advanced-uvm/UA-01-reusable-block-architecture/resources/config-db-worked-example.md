# Worked example: configuring a reusable accelerator environment

This is an illustrative architecture example, not a learner TODO or the source
for UA-02.

## Scenario

Suppose an accelerator has three interfaces:

- a control-register bus driven by this testbench;
- an input stream driven by this testbench;
- an output stream driven by the DUT and observed passively.

The environment reuses two protocol UVC types:

```text
uvm_test_top.env
├── ctrl_agent       active control-bus UVC
├── input_agent      active stream UVC
├── output_agent     passive stream UVC
├── predictor        accelerator-specific
├── scoreboard       accelerator-specific
└── coverage         accelerator-specific
```

The HDL top owns concrete interface instances. The test selects block policy.
The environment distributes agent-specific configuration. Each agent consumes
only its own configuration object.

## Configuration classes

Each protocol owns the configuration type whose fields have protocol meaning:

```systemverilog
class ctrl_agent_cfg extends uvm_object;
    `uvm_object_utils(ctrl_agent_cfg)

    virtual ctrl_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    int unsigned response_timeout_cycles = 32;

    function new(string name = "ctrl_agent_cfg");
        super.new(name);
    endfunction
endclass

class stream_agent_cfg extends uvm_object;
    `uvm_object_utils(stream_agent_cfg)

    virtual stream_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    bit allow_backpressure = 1'b1;
    int unsigned max_stall_cycles = 16;

    function new(string name = "stream_agent_cfg");
        super.new(name);
    endfunction
endclass
```

The block environment owns a configuration object that composes the UVC
configurations and carries block-level policy:

```systemverilog
class accel_env_cfg extends uvm_object;
    `uvm_object_utils(accel_env_cfg)

    ctrl_agent_cfg   ctrl_cfg;
    stream_agent_cfg input_cfg;
    stream_agent_cfg output_cfg;

    bit checks_enabled   = 1'b1;
    bit coverage_enabled = 1'b1;

    function new(string name = "accel_env_cfg");
        super.new(name);
    endfunction
endclass
```

The block configuration contains agent configurations; it does not absorb
protocol-specific fields such as stream stall policy into one flat global bag.

## Step 1: HDL top publishes concrete interfaces

Only the static module can directly name the concrete interface instances:

```systemverilog
module tb_top;
    import uvm_pkg::*;
    import accel_tb_pkg::*;

    logic clk;
    ctrl_if   ctrl_vif(clk);
    stream_if input_vif(clk);
    stream_if output_vif(clk);

    accelerator dut (
        .clk       (clk),
        .ctrl      (ctrl_vif),
        .input_s   (input_vif),
        .output_s  (output_vif)
    );

    initial begin
        uvm_config_db #(virtual ctrl_if)::set(
            null, "uvm_test_top", "ctrl_vif", ctrl_vif
        );
        uvm_config_db #(virtual stream_if)::set(
            null, "uvm_test_top", "input_vif", input_vif
        );
        uvm_config_db #(virtual stream_if)::set(
            null, "uvm_test_top", "output_vif", output_vif
        );
        run_test();
    end
endmodule
```

Interpret one call:

```text
set(null, "uvm_test_top", "ctrl_vif", ctrl_vif)
    │            │              │          │
 context     target scope    field name   stored handle
```

Using `null` makes the path absolute. The value is a virtual-interface handle,
not copied interface state.

## Step 2: the test retrieves interfaces and selects policy

The test assembles the complete block configuration before creating the
environment:

```systemverilog
class accel_base_test extends uvm_test;
    `uvm_component_utils(accel_base_test)

    accel_env_cfg cfg;
    accel_env     env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        virtual ctrl_if   ctrl_vif;
        virtual stream_if input_vif;
        virtual stream_if output_vif;

        super.build_phase(phase);

        if (!uvm_config_db #(virtual ctrl_if)::get(
                this, "", "ctrl_vif", ctrl_vif))
            `uvm_fatal("ACCEL_CFG", "missing control interface")

        if (!uvm_config_db #(virtual stream_if)::get(
                this, "", "input_vif", input_vif))
            `uvm_fatal("ACCEL_CFG", "missing input-stream interface")

        if (!uvm_config_db #(virtual stream_if)::get(
                this, "", "output_vif", output_vif))
            `uvm_fatal("ACCEL_CFG", "missing output-stream interface")

        cfg = accel_env_cfg::type_id::create("cfg");
        cfg.ctrl_cfg =
            ctrl_agent_cfg::type_id::create("ctrl_cfg");
        cfg.input_cfg =
            stream_agent_cfg::type_id::create("input_cfg");
        cfg.output_cfg =
            stream_agent_cfg::type_id::create("output_cfg");

        cfg.ctrl_cfg.vif = ctrl_vif;
        cfg.ctrl_cfg.is_active = UVM_ACTIVE;

        cfg.input_cfg.vif = input_vif;
        cfg.input_cfg.is_active = UVM_ACTIVE;
        cfg.input_cfg.allow_backpressure = 1'b1;

        cfg.output_cfg.vif = output_vif;
        cfg.output_cfg.is_active = UVM_PASSIVE;

        cfg.checks_enabled = 1'b1;
        cfg.coverage_enabled = 1'b1;

        uvm_config_db #(accel_env_cfg)::set(
            this, "env", "cfg", cfg
        );

        env = accel_env::type_id::create("env", this);
    endfunction
endclass
```

Here `this` is `uvm_test_top`, so target `"env"` resolves to
`uvm_test_top.env`.

The test chooses:

- which interfaces belong to this environment instance;
- which agents are active or passive;
- block-level enable policy.

It does not create drivers or reach inside the future agents.

## Step 3: the environment consumes and distributes configuration

The environment retrieves one block configuration, validates it, then publishes
each protocol configuration to the component that owns its meaning:

```systemverilog
class accel_env extends uvm_env;
    `uvm_component_utils(accel_env)

    accel_env_cfg cfg;
    ctrl_agent    ctrl_agent;
    stream_agent  input_agent;
    stream_agent  output_agent;
    accel_predictor predictor;
    accel_scoreboard scoreboard;
    accel_coverage coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(accel_env_cfg)::get(
                this, "", "cfg", cfg))
            `uvm_fatal("ACCEL_CFG", "environment did not receive cfg")

        if ((cfg.ctrl_cfg == null) ||
            (cfg.input_cfg == null) ||
            (cfg.output_cfg == null))
            `uvm_fatal("ACCEL_CFG", "agent configuration is incomplete")

        uvm_config_db #(ctrl_agent_cfg)::set(
            this, "ctrl_agent", "cfg", cfg.ctrl_cfg
        );
        uvm_config_db #(stream_agent_cfg)::set(
            this, "input_agent", "cfg", cfg.input_cfg
        );
        uvm_config_db #(stream_agent_cfg)::set(
            this, "output_agent", "cfg", cfg.output_cfg
        );

        ctrl_agent =
            ctrl_agent::type_id::create("ctrl_agent", this);
        input_agent =
            stream_agent::type_id::create("input_agent", this);
        output_agent =
            stream_agent::type_id::create("output_agent", this);

        if (cfg.checks_enabled) begin
            predictor =
                accel_predictor::type_id::create("predictor", this);
            scoreboard =
                accel_scoreboard::type_id::create("scoreboard", this);
        end

        if (cfg.coverage_enabled)
            coverage =
                accel_coverage::type_id::create("coverage", this);
    endfunction
endclass
```

For example, with environment context `uvm_test_top.env`, target
`"output_agent"` resolves to:

```text
uvm_test_top.env.output_agent
```

The environment sets each entry before the corresponding child reaches its
`build_phase`.

## Step 4: each agent consumes only its protocol configuration

The stream agent does not retrieve the full accelerator configuration:

```systemverilog
class stream_agent extends uvm_agent;
    `uvm_component_utils(stream_agent)

    stream_agent_cfg cfg;
    stream_monitor   monitor;
    stream_sequencer sequencer;
    stream_driver    driver;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(stream_agent_cfg)::get(
                this, "", "cfg", cfg))
            `uvm_fatal("STREAM_CFG",
                $sformatf("%s did not receive cfg", get_full_name()))

        is_active = cfg.is_active;

        uvm_config_db #(stream_agent_cfg)::set(
            this, "monitor", "cfg", cfg
        );
        monitor =
            stream_monitor::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE) begin
            uvm_config_db #(stream_agent_cfg)::set(
                this, "driver", "cfg", cfg
            );
            sequencer =
                stream_sequencer::type_id::create("sequencer", this);
            driver =
                stream_driver::type_id::create("driver", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );
    endfunction
endclass
```

Consequences:

- `input_agent` builds monitor, sequencer, and driver.
- `output_agent` builds only its monitor.
- both monitor instances receive the correct interface through their own
  `stream_agent_cfg`;
- the reusable stream agent has no knowledge of accelerator prediction or
  checking.

## Complete propagation trace

```text
tb_top.input_vif
  └─ config_db virtual-interface entry for uvm_test_top
      └─ accel_base_test retrieves handle
          └─ cfg.input_cfg.vif
              └─ config_db agent-config entry for env.input_agent
                  └─ input_agent retrieves cfg
                      ├─ monitor receives cfg and observes input_vif
                      └─ driver receives cfg and drives input_vif

tb_top.output_vif
  └─ config_db virtual-interface entry for uvm_test_top
      └─ accel_base_test retrieves handle
          └─ cfg.output_cfg.vif, is_active=UVM_PASSIVE
              └─ config_db agent-config entry for env.output_agent
                  └─ output_agent retrieves cfg
                      └─ monitor receives cfg and observes output_vif
```

## Important handle behavior

`uvm_config_db::set()` stores the object handle. `get()` returns that same
object handle; it does not automatically clone the configuration.

Therefore, configure these objects before dependent components use them and
treat them as stable policy afterward. If two consumers must mutate settings
independently, give them distinct configuration objects or intentionally clone
the source object.

## Common failure modes

### Setting configuration too late

If the test sets `env.cfg` after the environment has already executed
`build_phase`, the environment's `get()` fails or it builds the wrong topology.

### Incorrect scope

Setting stream configuration at `"env.stream_agent"` does not configure
instances named `"env.input_agent"` and `"env.output_agent"` unless a matching
wildcard was intentionally used.

### Overly broad wildcard

```systemverilog
uvm_config_db #(stream_agent_cfg)::set(
    this, "env.*", "cfg", input_cfg
);
```

This can accidentally give the passive output agent the active input
configuration. Exact paths are preferable when instances require different
policy.

### Passing the full block configuration everywhere

Giving every driver and monitor the entire `accel_env_cfg` couples protocol
components to block architecture. A reusable stream driver should consume
stream configuration, not accelerator-level predictor and coverage policy.

### Using config_db to choose implementation type

A configuration field followed by:

```systemverilog
if (cfg.use_special_driver)
    driver = special_driver::type_id::create(...);
else
    driver = base_driver::type_id::create(...);
```

hard-codes type selection into the reusable component. UA-02 introduces factory
overrides for compatible implementation replacement. Configuration should
still carry instance data.

## Governing invariant

The component that understands a configuration field should consume it, and
every topology-affecting value must arrive before that component builds the
dependent topology.

## Prediction

Suppose `output_cfg.is_active` is accidentally set to `UVM_ACTIVE`, while the
real output producer is the DUT. Which component would appear unexpectedly,
and what concrete verification risk would that create?
