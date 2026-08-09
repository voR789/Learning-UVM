# Tagged Compute Stream (TCS) peripheral specification

## Interface

All signals are synchronous to the rising edge of `clk`. Reset `rst_n` is
active-low and synchronous.

A command is accepted only on an edge where `cmd_valid && cmd_ready` is true.
Its fields are `cmd_tag[3:0]`, `cmd_op[1:0]`, `cmd_a[7:0]`, and `cmd_b[7:0]`.

A response is transferred only on an edge where `rsp_valid && rsp_ready` is
true. Its fields are `rsp_tag[3:0]`, `rsp_status[1:0]`, and
`rsp_data[7:0]`.

The DUT may accept as many as four outstanding commands. Responses are emitted
in command-acceptance order. A tag identifies a command; software must not reuse
a tag while that tag is outstanding.

## Operations

| `cmd_op` | Meaning        | `rsp_data`           |               `rsp_status` |
| ---------: | -------------- | ---------------------- | ---------------------------: |
|          0 | wrapping add   | low 8 bits of`a + b` |                            0 |
|          1 | bitwise XOR    | `a ^ b`              |                            0 |
|          2 | saturating add | `min(a + b, 255)`    | 1 on saturation, otherwise 0 |
|          3 | unsupported    | 0                      |                            2 |

Nominal execution latency, measured from command acceptance to the earliest
edge on which its response may be valid, is 1, 2, 3, and 1 cycles for operations
0 through 3 respectively. Backpressure and earlier queued commands may delay a
response beyond that minimum. There is no maximum response latency while
`rsp_ready` is low.

## Stability and reset

- While `rsp_valid && !rsp_ready`, every response field and `rsp_valid` must
  remain stable.
- Command fields need only be sampled on an accepted command.
- During reset, `cmd_ready` and `rsp_valid` are low and all outstanding work is
  discarded.
- On the first edge after reset is released, the DUT may accept a command.

## Verification requirements

The environment must check values from this specification, not from DUT
internals. It must detect missing, duplicate, unexpected, mis-tagged, reordered,
and corrupted responses; protocol instability under response backpressure; and
incorrect reset flushing. Coverage must be based on passively observed accepted
commands and transferred responses.

Required coverage intent:

- every operation;
- saturating-add with and without saturation;
- response transfer after at least one stalled cycle;
- at least two simultaneously outstanding commands;
- reset while at least one command is outstanding, followed by clean recovery;
- operation crossed with zero/nonzero status for legal combinations only.
