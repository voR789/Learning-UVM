# Eight-bit combinational ALU specification

## Interface

The ALU is purely combinational and has no clock or reset.

### Inputs

- `a[7:0]`: first unsigned operand.
- `b[7:0]`: second unsigned operand.
- `op[2:0]`: operation selector.

### Outputs

- `result[7:0]`: operation result.
- `carry`: addition carry-out or subtraction no-borrow indication, as defined below.
- `zero`: asserted when `result` equals `8'h00`.
- `invalid`: asserted when `op` does not select a defined operation.

## Requirements

### REQ-ADD — Addition

For `op = 3'b000`, compute the unsigned nine-bit sum of `a + b`. Drive the low eight bits on `result` and bit eight on `carry`.

### REQ-SUB — Subtraction

For `op = 3'b001`, drive `(a - b) mod 256` on `result`. Set `carry` to one when `a >= b` (no borrow) and zero when `a < b` (borrow).

### REQ-AND — Bitwise AND

For `op = 3'b010`, drive `a & b` on `result` and drive `carry` low.

### REQ-OR — Bitwise OR

For `op = 3'b011`, drive `a | b` on `result` and drive `carry` low.

### REQ-XOR — Bitwise XOR

For `op = 3'b100`, drive `a ^ b` on `result` and drive `carry` low.

### REQ-INVALID — Undefined operation selectors

For `op` values `3'b101`, `3'b110`, and `3'b111`, drive `result = 8'h00`, `carry = 0`, and `invalid = 1`.

### REQ-ZERO — Zero flag

For every operation selector, assert `zero` exactly when `result == 8'h00`; otherwise deassert it.

### REQ-CARRY — Valid-operation status

For every defined operation, drive `invalid = 0`. For logical operations, `carry` must be zero. Addition and subtraction use the operation-specific `carry` behavior above.

## Stability expectation

After any input changes, outputs must settle to the specified combinational values without requiring a clock event. The verification plan should define when observation is safe without assuming zero simulation delay.
