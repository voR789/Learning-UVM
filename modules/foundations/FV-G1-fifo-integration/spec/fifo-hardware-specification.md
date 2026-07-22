# FV-G1 Synchronous FIFO Hardware Specification

Document ID: `FV-G1-SPEC`  
Revision: 1.0  
Date: 2026-07-17  
Status: Authoritative for FV-G1

## 1. Purpose and precedence

This document defines the complete externally observable behavior of the
single-clock FIFO used in FV-G1. Verification plans, reference models,
scoreboards, assertions, and coverage shall derive expected behavior from this
document rather than from `dut/sync_fifo.sv`.

If the RTL disagrees with this specification, the RTL is defective. If another
FV-G1 document disagrees with this specification, this specification takes
precedence.

The words **shall**, **shall not**, **should**, and **may** are normative:

- **shall** or **shall not** states a requirement.
- **should** states a recommendation that does not change DUT correctness.
- **may** states permitted behavior.

## 2. Scope

The DUT is a synchronous, single-clock, first-in-first-out storage element.
Writes append data at the tail. Accepted reads remove and return data from the
head.

The FV-G1 configuration is:

| Parameter | Value | Meaning |
|---|---:|---|
| `WIDTH` | 8 | Stored data width in bits |
| `DEPTH` | 4 | Maximum number of stored items |
| `PTR_W` | 2 | Internal pointer width |
| `CNT_W` | 3 | Width of the externally visible occupancy count |

### 2.1 Out of scope

The following behavior is not provided:

- asynchronous or dual-clock operation;
- first-word fall-through;
- programmable almost-full or almost-empty thresholds;
- overflow or underflow interrupt outputs;
- error correction or parity;
- flushing other than synchronous reset;
- defined behavior for `X` or `Z` on DUT inputs.

Verification stimulus shall drive `rst`, `wr_en`, and `rd_en` to known binary
values at every sampled rising edge. `wdata` must be known whenever a write is
expected to be accepted.

## 3. Interface

| Port | Direction | Width | Description |
|---|---|---:|---|
| `clk` | input | 1 | Rising-edge clock |
| `rst` | input | 1 | Active-high synchronous reset |
| `wr_en` | input | 1 | Write request |
| `rd_en` | input | 1 | Read request |
| `wdata` | input | `WIDTH` | Write data |
| `rdata` | output | `WIDTH` | Data returned by the most recently accepted read |
| `full` | output | 1 | FIFO cannot accept a write without a simultaneous policy exception; no such exception exists in this specification |
| `empty` | output | 1 | FIFO contains no readable item |
| `count` | output | `CNT_W` | Number of stored items |

## 4. Timing model

**FIFO-CLK-001:** All state changes shall occur in response to the rising edge
of `clk`.

**FIFO-CLK-002:** Inputs and pre-edge outputs used to determine an operation
shall be interpreted at the active rising edge before the edge's state update.

**FIFO-CLK-003:** Updated `count`, `full`, `empty`, and `rdata` shall be
observable after the active edge's sequential update has completed.

The verification environment should drive requests before the active edge and
sample registered results after nonblocking assignments from that edge have
settled.

## 5. State definitions

Let `occupancy_pre` be the number of stored items immediately before an active
edge. Legal occupancy is the inclusive range `0` through `DEPTH`.

**FIFO-STATE-001:** `count` shall equal the current occupancy.

**FIFO-STATE-002:** `empty` shall be asserted if and only if `count == 0`.

**FIFO-STATE-003:** `full` shall be asserted if and only if `count == DEPTH`.

**FIFO-STATE-004:** In normal operation, `count` shall remain within
`0 <= count <= DEPTH`.

The testbench reference model shall maintain its own expected occupancy. DUT
`count`, `full`, and `empty` are observations to check, not sources of expected
state.

## 6. Reset behavior

**FIFO-RST-001:** Reset shall be active high and synchronous.

**FIFO-RST-002:** When `rst == 1` at a rising edge, reset shall take priority
over read and write requests on that edge.

**FIFO-RST-003:** After a reset edge, `count` shall equal zero, `empty` shall
equal one, `full` shall equal zero, and `rdata` shall equal all zeros.

**FIFO-RST-004:** After a reset edge, no data written before that edge shall be
readable without first being written again.

**FIFO-RST-005:** Holding `rst == 1` across multiple rising edges shall keep the
externally visible reset state specified by `FIFO-RST-003`.

## 7. Operation acceptance

For an edge on which `rst == 0`, expected acceptance shall be calculated from
the request inputs and the independent pre-edge occupancy:

```text
write_accept = wr_en && (occupancy_pre < DEPTH)
read_accept  = rd_en && (occupancy_pre > 0)
```

The two acceptance decisions are independent. Neither request receives a
special bypass because the other request is asserted on the same edge.

**FIFO-ACC-001:** A write request shall be accepted exactly when
`wr_en == 1` and `occupancy_pre < DEPTH`.

**FIFO-ACC-002:** A read request shall be accepted exactly when
`rd_en == 1` and `occupancy_pre > 0`.

**FIFO-ACC-003:** DUT `full` and `empty` outputs shall not be used as the
reference model's oracle for acceptance. They shall be checked against the
independently predicted state.

### 7.1 Operation truth table

This table applies when `rst == 0`.

| Pre-edge state | `wr_en` | `rd_en` | Write accepted | Read accepted | Occupancy change |
|---|---:|---:|---:|---:|---:|
| Any legal state | 0 | 0 | 0 | 0 | 0 |
| Empty | 1 | 0 | 1 | 0 | +1 |
| Empty | 0 | 1 | 0 | 0 | 0 |
| Empty | 1 | 1 | 1 | 0 | +1 |
| Neither empty nor full | 1 | 0 | 1 | 0 | +1 |
| Neither empty nor full | 0 | 1 | 0 | 1 | -1 |
| Neither empty nor full | 1 | 1 | 1 | 1 | 0 |
| Full | 1 | 0 | 0 | 0 | 0 |
| Full | 0 | 1 | 0 | 1 | -1 |
| Full | 1 | 1 | 0 | 1 | -1 |

## 8. Write behavior

**FIFO-WR-001:** On an accepted write, the value of `wdata` sampled at the
active edge shall be appended after all items already stored before that edge.

**FIFO-WR-002:** An accepted write without an accepted read shall increase
occupancy by one.

**FIFO-WR-003:** A rejected write shall not change stored FIFO contents, write
ordering, or occupancy.

**FIFO-WR-004:** `wdata` shall have no functional effect when the write is
rejected or not requested.

## 9. Read behavior

**FIFO-RD-001:** On an accepted read, the oldest item stored before the active
edge shall be removed from the FIFO.

**FIFO-RD-002:** After an accepted read, `rdata` shall equal the removed item.

**FIFO-RD-003:** An accepted read without an accepted write shall decrease
occupancy by one.

**FIFO-RD-004:** When a read is rejected or not requested, `rdata` shall retain
its previous value unless reset is active.

**FIFO-RD-005:** A rejected read shall not change stored FIFO contents, read
ordering, or occupancy.

## 10. Simultaneous read and write behavior

**FIFO-SIM-001:** When both operations are accepted, the read shall return the
oldest item that was present before the edge; it shall not return the `wdata`
sampled on the same edge.

**FIFO-SIM-002:** When both operations are accepted, the new `wdata` shall be
appended after all unread items and occupancy shall remain unchanged.

**FIFO-SIM-003:** When both requests occur while empty, only the write shall be
accepted. There is no same-cycle write-to-read bypass, and `rdata` shall hold.

**FIFO-SIM-004:** When both requests occur while full, only the read shall be
accepted. The simultaneous write shall be rejected, and occupancy shall
decrease by one.

## 11. Ordering and capacity

**FIFO-ORD-001:** Across all accepted operations, items shall be returned in
the same order in which their writes were accepted.

**FIFO-ORD-002:** Pointer wraparound shall not change FIFO ordering or corrupt
unread data.

**FIFO-CAP-001:** The FIFO shall store exactly `DEPTH` items before asserting
`full`.

**FIFO-CAP-002:** The FIFO shall accept the write that changes occupancy from
`DEPTH - 1` to `DEPTH`.

**FIFO-CAP-003:** Once occupancy is `DEPTH`, additional writes shall be
rejected until an accepted read creates space.

**FIFO-CAP-004:** The FIFO shall permit repeated fill, drain, and pointer-wrap
cycles without loss, duplication, or reordering.

## 12. Cycle-level reference-model algorithm

The following algorithm is normative and intentionally independent of RTL
implementation details:

```text
At each rising edge:
  if rst:
    expected_queue.clear()
    expected_rdata = 0
  else:
    occupancy_pre = expected_queue.size()
    write_accept = wr_en && (occupancy_pre < DEPTH)
    read_accept  = rd_en && (occupancy_pre > 0)

    if read_accept:
      expected_rdata = expected_queue.pop_front()

    if write_accept:
      expected_queue.push_back(wdata)

  expected_count = expected_queue.size()
  expected_empty = (expected_count == 0)
  expected_full  = (expected_count == DEPTH)
```

The read is modeled before the write only to make the required pre-edge read
value explicit. Because both acceptance decisions use `occupancy_pre`, changing
the queue-update statement order shall not change acceptance.

## 13. Required verification traceability

The FV-G1 verification plan shall trace, at minimum:

| Plan feature | Normative requirements |
|---|---|
| Clock and sampling | `FIFO-CLK-001` through `FIFO-CLK-003` |
| Reset and reset priority | `FIFO-RST-001` through `FIFO-RST-005` |
| Independent acceptance prediction | `FIFO-ACC-001` through `FIFO-ACC-003` |
| Write and blocked-write behavior | `FIFO-WR-001` through `FIFO-WR-004` |
| Read, blocked-read, and `rdata` hold | `FIFO-RD-001` through `FIFO-RD-005` |
| Simultaneous boundary behavior | `FIFO-SIM-001` through `FIFO-SIM-004` |
| FIFO ordering and wraparound | `FIFO-ORD-001`, `FIFO-ORD-002` |
| Capacity and repeated fill/drain | `FIFO-CAP-001` through `FIFO-CAP-004` |
| Status consistency and legal occupancy | `FIFO-STATE-001` through `FIFO-STATE-004` |

Coverage may demonstrate that these scenarios occurred, but correctness shall
be established by independent checking and assertions.

## 14. Ambiguity policy

If a case is not explicitly defined above:

1. Do not infer behavior from the supplied RTL.
2. Record the ambiguity in the verification plan.
3. Resolve it as a specification decision before changing the checker.

No known externally observable operating case within the stated scope is left
intentionally undefined.
