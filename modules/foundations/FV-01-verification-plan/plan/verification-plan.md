# FV-01 Verification Plan

## Scope

This plan verifies the specified combinational ALU results and status outputs for every defined and undefined operation selector using representative directed 8-bit operands. It does not verify propagation-delay limits, implementation structure, or behavior when inputs contain unknown or high-impedance values.

## Assumptions

After driving stimulus, the testbench waits a nonzero simulation delay before sampling outputs, allowing the combinational logic to propagate through the DUT. No clock event is required.

## Test cases

| Test ID | Requirement ID | Test intent | Stimulus | Observations | Expected result | Failure criterion |
|---|---|---|---|---|---|---|
| TC-ADD-01 | REQ-ADD | Test basic addition functionality without carry | Non-overflow values, a = 8'd23, b = 8'd174, OP = 3'b000 | result[7:0], carry, zero, invalid | result = 8'd197, carry = 1'b0, zero = 1'b0, invalid = 1'b0 | result != 8'd197 or carry != 1'b0 or zero != 1'b0 or invalid != 1'b0 |
| TC-ADD-02 | REQ-ADD, REQ-CARRY | Test addition carry bit logic | Overflow values, a = 8'd198, b = 8'd235, OP = 3'b000 | result[7:0], carry, zero, invalid | result = 8'd177, carry = 1'b1, zero = 1'b0, invalid = 1'b0 | result != 8'd177 or carry != 1'b1 or zero != 1'b0 or invalid != 1'b0 |
| TC-ADD-03 | REQ-ADD, REQ-CARRY | Test addition carry boundary logic | a = 8'd198, b = 8'd58, OP = 3'b000 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b1, zero = 1'b1, invalid = 1'b0 | result != 8'd0 or carry != 1'b1 or zero != 1'b1 or invalid != 1'b0 |
| TC-SUB-01 | REQ-SUB | Test basic subtraction functionality without borrow | Non-borrow values, a = 8'd12, b = 8'd4, OP = 3'b001 | result[7:0], carry, zero, invalid | result = 8'd8, carry = 1'b1, zero = 1'b0, invalid = 1'b0 | result != 8'd8 or carry != 1'b1 or zero != 1'b0 or invalid != 1'b0 |
| TC-SUB-02 | REQ-SUB, REQ-CARRY | Test subtraction carry bit logic with borrow | Borrow values, a = 8'd124, b = 8'd132, OP = 3'b001 | result[7:0], carry, zero, invalid | result = 8'd248, carry = 1'b0, zero = 1'b0, invalid = 1'b0 | result != 8'd248 or carry != 1'b0 or zero != 1'b0 or invalid != 1'b0|
| TC-AND-01 | REQ-AND, REQ-CARRY | Test AND functionality | a = 8'b10110011, b = 8'b11110000, OP = 3'b010 | result[7:0], carry, zero, invalid | result = 8'b10110000, carry = 1'b0, zero = 1'b0, invalid = 1'b0 | result != 8'b10110000 or carry != 1'b0 or zero != 1'b0 or invalid != 1'b0 |
| TC-OR-01 | REQ-OR, REQ-CARRY | Test OR functionality | a = 8'b10100110, b = 8'b00110110, OP = 3'b011 | result[7:0], carry, zero, invalid | result = 8'b10110110, carry = 1'b0, zero = 1'b0, invalid = 1'b0 | result != 8'b10110110 or carry != 1'b0 or zero != 1'b0 or invalid != 1'b0 |
| TC-XOR-01 | REQ-XOR, REQ-CARRY | Test XOR functionality | a = 8'b11011111, b = 8'b00110010, OP = 3'b100 | result[7:0], carry, zero, invalid | result = 8'b11101101, carry = 1'b0, zero = 1'b0, invalid = 1'b0 | result != 8'b11101101 or carry != 1'b0 or zero != 1'b0 or invalid != 1'b0 |
| TC-INVALID-01 | REQ-INVALID, REQ-ZERO | Test invalid operand functionality | a = 8'b11011111, b = 8'b00110010, OP = 3'b101 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b1 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b1|
| TC-INVALID-02 | REQ-INVALID, REQ-ZERO | Test invalid operand functionality | a = 8'b11011111, b = 8'b00110010, OP = 3'b110 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b1 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b1|
| TC-INVALID-03 | REQ-INVALID, REQ-ZERO | Test invalid operand functionality | a = 8'b11011111, b = 8'b00110010, OP = 3'b111 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b1 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b1|
| TC-ZERO-01 | REQ-ZERO, REQ-ADD | Test zero port functionality with ADD | a = 8'd0, b = 8'd0, OP = 3'b000 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b0 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b0|
| TC-ZERO-02 | REQ-ZERO, REQ-SUB, REQ-CARRY | Test zero port functionality with SUB (also subtraction boundary logic) | a = 8'd21, b = 8'd21, OP = 3'b001 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b1, zero = 1'b1, invalid = 1'b0 | result != 8'd0 or carry != 1'b1 or zero != 1'b1 or invalid != 1'b0|
| TC-ZERO-03 | REQ-ZERO, REQ-AND | Test zero port functionality with AND | a = 8'b00001111, b = 8'b11110000, OP = 3'b010 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b0 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b0|
| TC-ZERO-04 | REQ-ZERO, REQ-OR | Test zero port functionality with OR | a = 8'b00000000, b = 8'b00000000, OP = 3'b011 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b0 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b0|
| TC-ZERO-05 | REQ-ZERO, REQ-XOR | Test zero port functionality with XOR | a = 8'b00001111, b = 8'b00001111, OP = 3'b100 | result[7:0], carry, zero, invalid | result = 8'd0, carry = 1'b0, zero = 1'b1, invalid = 1'b0 | result != 8'd0 or carry != 1'b0 or zero != 1'b1 or invalid != 1'b0|

## Completion criteria

Testing is complete when all planned test cases have executed and passed, every specified requirement is traced to a passing test, and no output mismatches remain unresolved.