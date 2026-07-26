# Programmable counter specification

## Interface

The DUT is an unsigned 8-bit synchronous counter.

| Signal | Direction | Meaning |
|---|---|---|
| `clk` | input | Rising-edge clock |
| `rst_n` | input | Active-low synchronous reset |
| `cmd_valid` | input | Apply `cmd` on this rising edge |
| `cmd[1:0]` | input | `0=LOAD`, `1=INC`, `2=DEC`, `3=CLEAR` |
| `load_value[7:0]` | input | Value used by LOAD |
| `count[7:0]` | output | Current counter value |

## Behavior

At every rising edge:

1. If `rst_n==0`, set `count` to zero.
2. Otherwise, if `cmd_valid==1`, execute exactly one command:
   - LOAD: `count = load_value`
   - INC: `count = count + 1`, wrapping `255 -> 0`
   - DEC: `count = count - 1`, wrapping `0 -> 255`
   - CLEAR: `count = 0`
3. Otherwise retain the prior count.

The observed transaction is authoritative after the command edge, once the
updated `count` is visible.
