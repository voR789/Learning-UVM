# Register-model setup flow

## Observable problem

A bus sequence can write an address, but it does not know that the address is a
named control register with fields, access policy, reset value, and mirrored
state. Copying those details into every test makes register verification brittle.

UVM RAL supplies one model that translates named register operations into bus
traffic and tracks the state observed on that bus.

## Four responsibilities

- A **register block** owns registers and address maps.
- A **map** relates each register to a byte offset and selects a bus sequencer.
- An **adapter** translates between `uvm_reg_bus_op` and the bus item type.
- A **predictor** consumes observed completed bus items and updates the mirror.

The governing invariant is:

> The frontdoor map and predictor must describe the same address space and use
> the same bus translation.

## API field guide

RAL has a construction stage, a connection stage, and a use stage. The names
below are the important API calls for this module.

### 1. Define one register and its fields

A register class extends `uvm_reg`. Its constructor describes the container;
its `build()` function creates the fields inside the container.

```systemverilog
function new(string name = "period_reg");
    super.new(name, 16, UVM_NO_COVERAGE);
endfunction

virtual function void build();
    period = uvm_reg_field::type_id::create("period");
    period.configure(this, 16, 0, "RW", 0, 0, 1, 0, 0);
endfunction
```

`uvm_reg::new(name, n_bits, has_coverage)` means:

| Parameter        | Meaning                                                  |
| ---------------- | -------------------------------------------------------- |
| `name`         | UVM object name used in reports and hierarchy.           |
| `n_bits`       | Total width of the whole register.                       |
| `has_coverage` | RAL coverage-model mask;`UVM_NO_COVERAGE` disables it. |

`uvm_reg_field::configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)` means:

| Parameter                   | Meaning                                                              |
| --------------------------- | -------------------------------------------------------------------- |
| `parent`                  | The containing`uvm_reg`.                                           |
| `size`, `lsb_pos`       | Field width and least-significant bit position.                      |
| `access`                  | Software access policy such as`"RW"`, `"RO"`, or `"WO"`.       |
| `volatile`                | Hardware may change the field independently of software writes.      |
| `reset`, `has_reset`    | Reset value and whether it is modeled.                               |
| `is_rand`                 | Whether RAL randomization should vary this field.                    |
| `individually_accessible` | Whether the bus can address this field separately from its register. |

`type_id::create()` is UVM factory construction. It creates a testbench object;
it does not create any hardware signal in the DUT.

### 2. Put the register into a block and address map

A block extends `uvm_reg_block`. Its `build()` function owns register instances
and maps. The usual lifecycle is:

```text
factory-create register → configure it under block → build its fields
→ create map → add register at byte offset → lock model
```

The relevant APIs are:

| API                                                          | Meaning                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------- |
| `reg.configure(block, null, "")`                           | Makes the register a child of the block.                      |
| `reg.build()`                                              | Creates/configures the register's fields.                     |
| `create_map(name, base, n_bytes, endian, byte_addressing)` | Creates an address map.`n_bytes` is the bus width in bytes. |
| `map.add_reg(reg, offset, rights)`                         | Gives a register a byte offset and map-level access rights.   |
| `lock_model()`                                             | Freezes model topology after construction.                    |

For a 32-bit bus, `n_bytes` is `4`. With byte addressing enabled, an offset of
`'h4` means four bytes after the map base, not four register words after it.

### 3. Connect the map and predictor in the environment

Construction only describes the address space. The environment binds it to the
actual bus verification path:

```text
map.set_sequencer(bus_sequencer, adapter)
map.set_auto_predict(0)
predictor.map = map
predictor.adapter = adapter
completed_bus_analysis_port.connect(predictor.bus_in)
```

### What each connection actually does

It helps to separate three different kinds of setup. They look similar in code,
but they do not have the same mechanics.

| Kind                           | Example                                                     | What it means                                                                                                                       |
| ------------------------------ | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **TLM connection**       | `driver.seq_item_port.connect(sequencer.seq_item_export)` | Establishes a request/response channel. A sequence item can now travel from a sequencer to the driver.                              |
| **Handle assignment**    | `predictor.map = map`                                     | Gives one object a reference to another object so it can consult its metadata. No transaction moves at this line.                   |
| **Registration/routing** | `map.set_sequencer(sequencer, adapter)`                   | Records which sequencer and adapter RAL should use later when a frontdoor operation is requested. No bus item is sent at this line. |

The same distinction applies to the predictor: assigning `predictor.map` and
`predictor.adapter` tells it how to decode observations, while connecting an
analysis port to `predictor.bus_in` is what actually delivers observations.

### The complete UA-08 path, one write at a time

Assume the test calls a frontdoor write on a named register.

1. **The test expresses intent.** `control.write(...)` asks RAL to write the
   register value. The test does not create `ua08_bus_item` or choose an address
   manually.
2. **The map resolves the address.** Because `control` was added to a map at
   offset `0x0`, the map constructs a generic `uvm_reg_bus_op` whose address is
   the map base plus that offset. It also knows the map's byte width and
   endianness.
3. **`set_sequencer()` selects the frontdoor.** RAL looks up the sequencer and
   adapter previously registered for this map. Internally, RAL starts a small
   bus sequence on that sequencer. It does *not* call the driver directly.
4. **The adapter translates representation.** RAL calls
   `adapter.reg2bus(rw)`. The adapter converts the generic operation fields
   (`kind`, `addr`, and `data`) into the project-specific bus item. In UA-08,
   that item is `ua08_bus_item`.
5. **Normal UVM sequencing takes over.** The internal RAL sequence sends the
   bus item through the sequencer. The already-connected driver receives it via
   `get_next_item()`, performs the modeled DUT operation, supplies the status,
   then calls `item_done()`.
6. **The operation path returns status.** RAL converts the completed item back
   through `adapter.bus2reg(...)` as needed and returns the resulting
   `uvm_status_e` to `control.write(status, ...)`. This tells the caller whether
   the frontdoor operation succeeded.
7. **The observation path updates the mirror.** Independently, the driver
   publishes the completed bus item on its analysis port. The predictor receives
   that item at `bus_in`, uses its `map` to find which register address it
   represents, uses its `adapter` to decode the item, and updates the matching
   register's mirror.

The key idea is that steps 1–6 perform an operation, while step 7 models what
was *observed* on the bus. Keeping those paths separate is why this module
disables automatic prediction.

```text
frontdoor operation:
test → uvm_reg.write → map → reg2bus → sequencer → driver
                                           ↓
observed completion:
mirror ← predictor ← bus2reg ← analysis port ← completed bus item
```

### Why all five connection actions are necessary

| Missing setup                                               | Consequence                                                                                         |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `driver.seq_item_port.connect(sequencer.seq_item_export)` | The sequencer has no driver to consume its generated bus item.                                      |
| `map.set_sequencer(sequencer, adapter)`                   | A frontdoor`write()` has no registered bus route.                                                 |
| `map.set_auto_predict(0)`                                 | The mirror can update from the request itself, hiding a broken observation path.                    |
| `predictor.map = map` or `predictor.adapter = adapter`  | The predictor cannot reliably turn an observed item into the right register update.                 |
| `completed_ap.connect(predictor.bus_in)`                  | The bus operation can succeed, but the mirror remains stale because the predictor observes nothing. |

### What the supplied objects are in UA-08

| Object        | Role in this module                                                |
| ------------- | ------------------------------------------------------------------ |
| `model`     | The`ua08_reg_block` containing `control` and `default_map`.  |
| `sequencer` | Receives the internal RAL-generated bus sequence.                  |
| `adapter`   | Defines`reg2bus()` and `bus2reg()` for `ua08_bus_item`.      |
| `driver`    | Models the DUT-side bus action and publishes completed items.      |
| `predictor` | Decodes published completed items and updates the register mirror. |

There is only one map and one bus path in UA-08. In a larger environment, a
block may have several maps; each can be registered to a different sequencer
and adapter, giving the same register model multiple frontdoor access paths.

| API                                         | Path responsibility                                                |
| ------------------------------------------- | ------------------------------------------------------------------ |
| `map.set_sequencer(...)`                  | Frontdoor path: chooses where a`reg.write()` transaction starts. |
| `adapter.reg2bus(...)`                    | Converts the generic RAL operation into the project bus-item type. |
| `map.set_auto_predict(0)`                 | Prevents the write call itself from silently updating the mirror.  |
| `predictor.map` / `predictor.adapter`   | Lets observed bus items be decoded back into register operations.  |
| `analysis_port.connect(predictor.bus_in)` | Observation path: delivers completed bus traffic to the predictor. |

The adapter's inverse pair is important:

```text
reg2bus: uvm_reg_bus_op   → project bus item
bus2reg: project bus item → uvm_reg_bus_op
```

### 4. Use the model from a test

The test uses register-level intent, not raw addresses:

```systemverilog
timer_regs.period.write(status, 'h0032, UVM_FRONTDOOR, timer_regs.default_map);
mirrored = timer_regs.period.get_mirrored_value();
```

`write()` starts the frontdoor path. `get_mirrored_value()` reads the RAL
model's observed state; it does not perform another bus read. In this module,
the mirror should change only after the completed bus item reaches the
predictor.

The write path is:

```text
register.write → map → adapter.reg2bus → sequencer → driver
```

The observation path is:

```text
completed bus item → predictor → adapter.bus2reg → register mirror
```

Turning off automatic prediction makes the second path meaningful: the mirror
changes because completed traffic was observed, not merely because a test asked
for a write.

## Separate worked example

Suppose a timer has a 16-bit `period` register at offset `0x8`. Its block:

1. creates and builds the `period` register;
2. creates a little-endian map with the bus byte width;
3. adds `period` at `0x8`;
4. locks the model after construction.

The environment then calls `set_sequencer()` on that map with a timer-bus
sequencer and adapter, disables auto-predict, assigns the map and adapter into
a predictor, and connects completed timer-bus observations into the predictor.
A test can call `period.write(...)` without constructing a timer-bus item.

The timer model is separate from UA-08: do not copy the timer names into your
submission. Transfer the responsibilities and API order to the supplied control
register and environment.

## Field configuration used here

The supplied control register already defines:

- `enable`: bit 0, read/write, reset 0;
- `mode`: bits 2:1, read/write, reset 0;
- register width: 32 bits.

You are not being asked to transcribe field configuration in this module. The
new reasoning is block/map construction and environment integration.

## XSim discipline

Use explicit null guards before dereferencing model handles. Do not place a
method call through a possibly null handle in a ternary expression.

## Prediction

If the driver completes a write successfully but completed traffic never
reaches the predictor, what should happen to the DUT-side stored value and the
RAL mirror?
