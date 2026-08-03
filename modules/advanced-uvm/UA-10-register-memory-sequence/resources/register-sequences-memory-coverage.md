# Register sequences, memories, checking, and coverage

## Observable problem

A register model can translate a valid logical memory index into an incorrect
physical address. Every bus access may still return `UVM_IS_OK`, yet two
logical locations can overwrite each other. Status checking alone cannot find
that fault.

The governing invariant is: **retain expected data independently, then compare
it with a later observation from each logical location.**

## 1. Why use a `uvm_reg_sequence`

A `uvm_reg_sequence` packages register-level intent for reuse across tests. It
does not replace the map, adapter, sequencer, or driver. Calls made in its
`body()` still use the register model's configured frontdoor.

Minimal shape:

```systemverilog
class timer_memory_seq extends uvm_reg_sequence;
    timer_reg_block model;

    task body();
        // Use model registers or memories here.
    endtask
endclass
```

The test assigns the model handle and starts this high-level sequence. In this
module the supplied test performs those mechanics; you own only `body()`.

## 2. `uvm_mem` models indexed addressable storage

The supplied block contains:

```systemverilog
uvm_mem scratch;
```

It represents four 32-bit logical locations. Unlike `uvm_reg`, `uvm_mem` does
not maintain a mirrored and desired value for every location. Tracking a large
memory that way would consume excessive simulation memory. Readback data must
therefore be compared with a separate expected value or memory model.

The frontdoor APIs are:

```systemverilog
model.scratch.write(
    status, index, value, UVM_FRONTDOOR, model.default_map, this);

model.scratch.read(
    status, index, observed, UVM_FRONTDOOR, model.default_map, this);
```

Here `index` is a logical memory index, not a byte address. The map converts it
to:

```text
mapped address = memory base + index * bus bytes per location
```

For this module, base `0x10` and four bytes per location mean:

| Logical index | Frontdoor byte address |
|---:|---:|
| 0 | `0x10` |
| 1 | `0x14` |
| 2 | `0x18` |
| 3 | `0x1C` |

## 3. Check status and data separately

After every operation, first require:

```systemverilog
status == UVM_IS_OK
```

For a read, that only proves the access completed. It does not prove the
returned data is correct.

Keep distinct expected values:

```systemverilog
expected0 = 32'h1111_0001;
expected1 = 32'h2222_0002;
```

Then compare each later observation with the corresponding expectation.
Distinct patterns are essential: if both expectations were equal, aliased
locations could escape detection.

Use `UA10_STATUS` for a failed access and `UA10_DATA` for incorrect readback.
Increment the supplied `verified` count only after a readback matches.

## 4. Sequence checking versus a scoreboard

A bounded register sequence can check the data returned by its own directed
read because it retained an independent expectation. That is useful for a
reusable register-level procedure.

It does not replace passive end-to-end checking. A full environment still uses
monitored traffic, prediction, and a scoreboard when it must detect behavior
outside this sequence's own calls. UA-G1 will transfer the RAL flow back into
that integration architecture.

## 5. Register coverage is not created by a flag

RAL objects provide coverage-management methods such as:

```systemverilog
has_coverage(...)
set_coverage(...)
get_coverage(...)
sample_values()
```

Those APIs enable or query a coverage model that a generated or derived
register class actually implements. Passing `UVM_CVR_ALL` does not manufacture
meaningful covergroups automatically.

For this memory-check scenario, useful intent would include:

- logical indices `0` and `1` both accessed;
- read and write operations both observed at each index;
- distinct data classes or boundary patterns where required by the
  specification.

The supplied checker exposes per-index read/write counts as executable evidence.
A production environment could sample the same observed bus transactions into
a functional covergroup. Reauthoring that already-practiced covergroup
mechanics is not the new objective here, so coverage implementation is a
reading checkpoint.

## Separate worked example

A timer block contains a two-entry table. A reusable sequence writes
`0x15` to index `0` and `0x2A` to index `1`, then reads both. Its expected
values live in sequence variables, not in the returned transaction. If an
address decoder drops the index bit, the second write overwrites index `0` and
the later read of index `0` exposes the alias.

That timer example is separate from UA-10. Apply its invariant using the
scratch-memory patterns specified in the README.

## Prediction

Would enabling `UVM_CVR_ALL` on a class with no implemented covergroup produce
useful functional coverage? What observation would a memory-index coverage
model need to sample?
