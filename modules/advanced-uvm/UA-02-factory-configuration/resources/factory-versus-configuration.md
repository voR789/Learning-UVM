# Factory overrides and configuration: a practical mental model

## What problem are we solving?

A reusable environment often needs to vary in two different ways:

1. **Behavior implementation:** use a compatible but different class at a
   construction point.
2. **Instance data:** give each constructed instance different values or
   operating policy.

Those are deliberately separate mechanisms:

| Question                                      | UVM mechanism                         | Example                                                   |
| --------------------------------------------- | ------------------------------------- | --------------------------------------------------------- |
| Which class should the factory create?        | Factory override                      | Replace`base_codec` with `crc_codec`.                 |
| What values should this created instance use? | Configuration object and`config_db` | Give transmitter polynomial 7 and receiver polynomial 11. |

If an environment uses an `if` statement to choose a derived class, the
environment now knows every implementation option. If a new implementation is
added, the reusable environment must change. The factory prevents that coupling.

## First: what the factory actually does

Registration gives UVM a mapping from a type name to a factory proxy. It does
**not** create an object or component.

```systemverilog
class base_codec extends uvm_component;
    `uvm_component_utils(base_codec)
    // ...
endclass
```

This is ordinary factory construction:

```systemverilog
codec = base_codec::type_id::create("codec", this);
```

Without an override, `codec` is a `base_codec`. With a compatible override,
the source line stays exactly the same, but the factory can return a derived
object instead:

```text
requested through create(): base_codec
factory rule:              base_codec -> crc_codec
actual constructed type:   crc_codec
handle declaration type:   base_codec
```

The base-class handle is intentional. It lets the unchanged environment use a
stable API while a derived class supplies different virtual behavior.

## The one non-negotiable rule

> A factory override can affect only a later factory `create()` call.

So this ordering works:

```text
install override
→ environment factory-creates child
→ child has override type
```

This ordering does not:

```text
environment factory-creates child
→ install override
→ existing child remains its original type
```

And this bypasses the factory entirely:

```systemverilog
codec = new("codec", this);
```

`new()` constructs the class named in the source. No factory lookup occurs, so
no override can participate.

## Type override: replace every matching request

A **type override** says: “Whenever the factory is later asked for this base
type, create this compatible derived type instead.”

Separate worked example:

```systemverilog
class base_codec extends uvm_component;
    `uvm_component_utils(base_codec)
    virtual function string mode(); return "base"; endfunction
endclass

class crc_codec extends base_codec;
    `uvm_component_utils(crc_codec)
    virtual function string mode(); return "crc"; endfunction
endclass

function void build_phase(uvm_phase phase);
    base_codec::type_id::set_type_override(crc_codec::get_type());
    tx_codec = base_codec::type_id::create("tx_codec", this);
    rx_codec = base_codec::type_id::create("rx_codec", this);
endfunction
```

Both `tx_codec` and `rx_codec` are actually `crc_codec` instances because both
were factory requests for `base_codec` after the global rule was installed.

Use a type override when the replacement should be true across the intended
scope of the test: for example, turning every normal codec in a test into a
CRC-aware codec.

## Instance override: replace one future path

An **instance override** says: “Only when this base type is requested at this
specific future hierarchy path, create the derived type instead.”

```systemverilog
base_codec::type_id::set_inst_override(
    parity_codec::get_type(),
    "uvm_test_top.env.rx_codec"
);

tx_codec = base_codec::type_id::create("tx_codec", this);
rx_codec = base_codec::type_id::create("rx_codec", this);
```

Result:

```text
uvm_test_top.env.tx_codec  -> base_codec
uvm_test_top.env.rx_codec  -> parity_codec
```

The string is the **future full instance path**. It is not a class name and is
not a `config_db` scope. The factory compares the requested base type and the
future instance path to decide whether its rule matches.

Use an instance override when only one role needs specialized behavior: for
example, one receive-side checker needs packet reordering but the transmit-side
checker remains normal.

## Configuration is not an alternate factory

Suppose both codecs are still `crc_codec`, but use different polynomial values.
That is configuration data, not a reason to create two more derived classes:

```systemverilog
class codec_cfg extends uvm_object;
    `uvm_object_utils(codec_cfg)
    int unsigned polynomial;
    bit          check_enabled;
endclass

tx_cfg.polynomial = 7;
rx_cfg.polynomial = 11;

uvm_config_db #(codec_cfg)::set(this, "env.tx_codec", "cfg", tx_cfg);
uvm_config_db #(codec_cfg)::set(this, "env.rx_codec", "cfg", rx_cfg);
```

Both base and derived codecs can retrieve `codec_cfg` in their `build_phase`.
The runtime class tells you *how* the codec acts; its configuration object
tells that one instance *which values* to use.

## One complete separate worked example

Imagine a reusable memory-bus agent instantiated twice:

```text
uvm_test_top.bridge_env
├── host_agent
└── device_agent
```

The agent environment always requests `base_bus_driver` through the factory.
The default driver drives requests immediately. A `delayed_bus_driver` has the
same driver API but waits a configurable number of cycles before driving.

### Test A: make all drivers delayed

```text
type override: base_bus_driver -> delayed_bus_driver
configuration:
  host_agent.cfg.delay_cycles   = 2
  device_agent.cfg.delay_cycles = 5
```

Both agents construct `delayed_bus_driver`; their different delays come from
their own configuration objects.

### Test B: delay only the device side

```text
instance override:
  base_bus_driver at uvm_test_top.bridge_env.device_agent.driver
  -> delayed_bus_driver

configuration:
  host_agent.cfg.delay_cycles   = 0
  device_agent.cfg.delay_cycles = 5
```

Now host uses `base_bus_driver`; device uses `delayed_bus_driver`. The
environment source was not edited for either test.

## Map that to UA-02

UA-02 is intentionally smaller, but follows the same mechanics:

```text
base policy is the requested factory type
add policy and XOR policy are compatible replacement types
left and right are two future factory paths
left_cfg and right_cfg provide distinct operands
```

The supplied base test does this in order:

```text
derived test's configure()
  1. builds the two configuration objects
  2. publishes each to the appropriate future child path
  3. installs any factory rule

base test's build_phase()
  4. factory-creates env

environment's build_phase()
  5. factory-creates left and right policies

policy build_phase()
  6. retrieves its own configuration object
```

The exact order is why the two TODOs live in `configure()`: they must execute
before `env` creates `left` and `right`.

## Trace the expected behavior before coding

The input value is `0x12`, which is decimal 18.

| Run                    | `left` requested as | `right` requested as | Expected actual policy types | Config operands | Results                                             |
| ---------------------- | --------------------- | ---------------------- | ---------------------------- | --------------- | --------------------------------------------------- |
| Starter type test      | base                  | base                   | base, base                   | 3, 7            | 18, 18 — intentionally fails expected add behavior |
| Type override test     | base                  | base                   | add, add                     | 3, 7            | 21, 25                                              |
| Instance override test | base                  | base                   | base, XOR                    | 3, 7            | 18, 21                                              |

The important observation is that the factory request remains `base` in all
three cases. Only the factory rules change the actual runtime type.

## Debugging checklist

When an override seems ignored, ask these in order:

1. Was the child created with `type_id::create()`, not `new()`?
2. Was the override installed before that `create()` call?
3. Is the override type derived from, and therefore assignment-compatible with,
   the requested base type?
4. For an instance override, is the path the exact future full instance path?
5. Did an earlier matching instance rule take precedence, or did no instance
   rule match and a type override apply?
6. Is the reported behavior actually a configuration-data issue rather than a
   runtime-type issue?

Useful evidence is the UVM topology: it shows the actual component type at
each hierarchy path. Factory debug output can also show registered types and
installed overrides, but topology plus a behavioral check is normally the
clearest first proof.

## Common incorrect designs

### Direct derived construction in the environment

```systemverilog
if (test_name == "slow_test")
    driver = delayed_bus_driver::type_id::create("driver", this);
else
    driver = base_bus_driver::type_id::create("driver", this);
```

The environment now knows a test name and every variant. Put the selection in
the test through an override instead.

### One subclass for every data value

Creating `delay_2_driver`, `delay_5_driver`, and `delay_10_driver` is usually
a sign that configuration data has been made into type hierarchy. One
`delayed_bus_driver` plus a configurable `delay_cycles` field is more reusable.

### One shared mutable configuration object by accident

`config_db` transfers object handles. If the same configuration object is set
for both left and right and one consumer modifies it, both handles see that
change. UA-02 intentionally supplies separate left and right configuration
objects.

## Governing invariants

- Factory override: chooses a compatible runtime type at a future factory
  construction point.
- Configuration object: supplies stable per-instance data to the constructed
  component.
- The environment uses the base type and remains unaware of test-specific
  replacement classes.
- Every required override is installed before the matching `type_id::create()`.

## Prediction

Before touching UA-02, answer this:

> In the instance-override test, why must `left` remain a base policy even
> though `right` becomes an XOR policy, and which part of the factory rule
> distinguishes them?
