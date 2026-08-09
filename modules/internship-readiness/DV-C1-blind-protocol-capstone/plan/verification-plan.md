# DV-C1 verification plan

## Scope

Verifies full operation of TCS Design, including backpressure testing, response stressing, reset flusing, and normal operation.

## Requirement traceability

| Test ID          | Requirement ID                                          | Test intent                                                                                                                                       | Stimulus                                                                                                                                                                                                                                                           | Observations                                                          | Expected result                                                                                                                                                                                                                                                                                                                                                                                                 | Failure criterion                                                                                                                                 | Coverage evidence                                                                                                                                                                                  |
| ---------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TC-RST-01        | REQ-RST                                                 | Test basic reset capabilities with empty TCS                                                                                                      | Hold reset low for one cycle.                                                                                                                                                                                                                                      | cmd_ready and rsp_valid signals                                      | cmd_ready and rsp_valid are desasserted during reset.                                                                                                                                                                                                                                                                                                                                                           | DUT asserts cmd_ready or rsp_valid while reset is low                                                                                            | Basic reset and handshake boundary rules.                                                                                                                                                          |
| TC-RST-02        | REQ-RST, REQ-OP0                                        | Test reset with outstanding work, and clean recovery.                                                                                             | Drive wrapping add operation with a =`8'h01` and b = `8'h02`. After the first transaction is accepted, hold reset low for one cycle on the next rising edge. One the next rising edge, drive recovery operation (wrapping add, a =`8'h10` and b = `8'h20`) | Transfered rsp tag, status, and data.                                 | First transaction should not drive a response, reset should deassert cmd_ready and rsp_vaid, second transaction should ellicit response.                                                                                                                                                                                                                                                                        | First transaction is observed, second transaction is not observed, or reset handshake protocol is broken.                                        | Reset while command is outstanding, and clean recovery.                                                                                                                                            |
| TC-WRAP-ADD-01   | REQ-OP0                                                 | Test basic wrapping add functionality with and without overflow.                                                                                  | Start at reset state. Drive 3 wrapping add commands with constraint`a + b < 8'hFF`. Then drive 3 wrapping add commands with constraint `a + b > 8'hFF`.                                                                                                       | Transfered rsp tag, status, and data for each command.                | All commmand transactions should be accepted, follow latency and handshaking protocols, 6 responses should be recieved: tags should correspond to commands, status should be`0` for each, and data should be equal to the value of a wrapping add of `a` and `b`.                                                                                                                                         | One or more responses fail to propogate, or have incorrect response fields.                                                                       | Operation 0 with overflow and non overflow values,`cross op0 x status0`                                                                                                                          |
| TC-XOR-01        | REQ-OP1                                                 | Test bitwise XOR command.                                                                                                                         | Start at reset state. Drive 3 commands with`a` and `b` randomized.                                                                                                                                                                                            | Transfered rsp tag, status, and data for each command                 | All commmand transactions should be accepted, follow latency and handshaking protocols, 3 responses should be recieved, with matching tag fields, status =`0`, and data should be equal to the bitwise XOR of `a` and `b`.                                                                                                                                                                                | One or more responses faial to propogate, or have incorrect response fields                                                                       | Operation 1 wih various values.`cross op1 x status0`                                                                                                                                             |
| TC-SAT-ADD-01    | REQ-OP2                                                 | Test basic saturating add functionality with and without saturation.                                                                              | Start at reset state. Drive 3 non-saturating add commands with constraint`a + b < 8'hFF`. Then drive 3 saturating add commands with constraint `a + b > 8'hFF`.                                                                                               | Transfered rsp tag, status, and data for each command.                | All commmand transactions should be accepted, follow latency and handshaking protocols, 6 responses should be recieved: tags should correspond to commands, status should be`0` for the first three, and `1` for the last 3. Data for the first three should be equal to the value of a saturating add of `a`and`b`, data for the second three should be `8'hFF`.                                    | One or more responses fail to propogate, or have incorrect response fields.                                                                       | Operation 2 with saturating and non saturating values.`cross op2 x (status0 and status1)`                                                                                                        |
| TC-INVALID-OP-01 | REQ-OP3                                                 | Test invalid operation response.                                                                                                                  | Start at reset state. Drive 1 unsupposed command (`op = 3`), with `a = 8'hAA`and `b = 8'hBB` (sentinel values).                                                                                                                                              | Transfered rsp tag, status, and data for each command.                | Command transaction should be accepted, follow latency and handshaking protocols. Aceepted response should have matching tag, data =`0`, and status = `2`.                                                                                                                                                                                                                                                  | Response does not propogate, or fails to match unsupported command protocol..                                                                    | Operation 3.`cross op3 x status2`                                                                                                                                                                |
| TC-FULL-01       | REQ-RSP, REQ-BACK                                       | Test maximum commmand capacity, backpressure and clean recovery.                                                                                  | Start at reset state. Set the response-ready policy low. Drive 4 randomized commands with the normal hold-until-accepted policy. Issue command 5 as a one-cycle probe; after one unaccepted cycle, withdraw it. Assert response-ready and, after 4 responses have been accepted, drive one more randomized command. | Transfered rsp tag, status, and data for each accepted command.       | Command transactions 1-4 should be accepted, following latency and handshaking protocols. Command 5 should not be accepted, cmd_rdy =`0`. Before rsp_ready is asserted but rsp_valid = `1`, response 1 should be stable on the rsp bus. After 4 corresponding and correct responses have been accepted, command 5 should not have an equivalent response, and response for command 6 should propogate next. | Response 1 is not held stable whilst backpressure, responses 1-4 are not accepted/propogated, response 5 is accepted, response 6 is not accepted. | Test that TCL has max occupancuy of 4, TCL with 2+ outstanding commands, handles backpressure correctly, holding the response bus stable, and TCL operations work after max capacity stress test. |
| TC-LATENCY-01    | REQ-OP0, REQ-OP1, REQ-OP2, REQ-OP3                   | Test that commands have valid minimum latency in system, accounting for internal queue.                                                           | Start at reset state. then drive a randomzied data command 0, 1, 2, and 3.                                                                                                                                                                                         | Transfered rsp tag, status, and data for each command, cycle latency. | Command transactions should be accepted, following handshaking protocols, and responses should come in the same order. Latency difference between acceptance cycle and response cycle should be greater than or equal to specified minimums.                                                                                                                                                                   | Latency differences are less than specified minimums, or responses fail to match expected fields for tag, status, data.                           | Test basic minimum command latencies on TCL.                                                                                                                                                       |
| TC-LATENCY-02    | REQ-OP0, REQ-OP1, REQ-OP2, REQ-OP3, REQ-BACKPRESSURE | Test that commands have valid minimum latency, accounting for backpressure stalls and internal queue.                                             | Start at reset state. deassert rsp_ready, then drive a 4 randomzied data commands. After 2 commands have been driven, assert rsp_ready.                                                                                                                          | Transfered rsp tag, status, and data for each command, cycle latency. | Command transactions should be accepted, following handshaking protocols and responses should come in the same order. Latency difference should be greater or equal to specified minimums.                                                                                                                                                                                                                      | Latency differences are less than specified minimums, or responses fail to propogate or match expected fields for tag, status, data.             | Test basic minimum command latencies with more than one outstanding command and backpressure.                                                                                                      |
| TC-STRESS-01     | All                                                     | Randomzied cmd and rsp stress test. CMD will have randomized operations and values, while RSP will be randomized to simulate random backpressure. | Start at reset state, then send 10 randomized commands, and randomly toggle rsp_ready throughout at 25% chance of backpressure.                                                                                                                                    | Transfered rsp tag, status, and data for each command, cycle latency. | Command transactions should be accepted, following handshaking protocols and responses should come in the same order. Latency difference should be greater or equal to specified minimums.                                                                                                                                                                                                                      | Output responses from DUT do not match expected behavior of spec.                                                                                 | Test random values.                                                                                                                                                                                |

## Architecture decisions

**Transaction Items:**

*Request items*

- uvm_sequence_item: cmd_req

  - cmd_tag[3:0]
  - cmd_op[1:0]
  - cmd_a[7:0]
  - cmd_b[7:0]
  - drive policy: `HOLD_UNTIL_ACCEPT` (default) or `PULSE_ONE_CYCLE`
- uvm_sequence_item: rsp_req

  - rsp_ready
- uvm_sequence_item: rst_req

  - rst_n

*Observation items*

- uvm_object: cmd_obs

  - cmd_valid
  - cmd_ready
  - cmd_tag[3:0]
  - cmd_op[1:0]
  - cmd_a[7:0]
  - cmd_b[7:0]
  - acc_cycle
- uvm_object: rsp_obs

  - rsp_valid
  - rsp_ready
  - rsp_tag[3:0]
  - rsp_status[1:0]
  - rsp_data[7:0]
  - rsp_cycle
- uvm_object: rst_obs

  - rst_n

**Sequence**

*Virtual Sequences*

- uvm_sequence: tcs_seq_rst (virtual sequnce)
- uvm_sequence: tcs_test_op (virtual sequnce)
- uvm_sequence: tcs_test_protocol (virtual sequnce)
- uvm_sequence: tcs_test_stress (virtual sequnce)

*Leaf Sequences*

- uvm_sequence: command (leaf sequence) (cmd_req)

  - Issue a command stimulus based on internal properties.
  - Fields: cmd_tag, cmd_op, cmd_a, cmd_b, drive policy

**Command intent versus handshake**

- Sequences choose functional command fields and drive policy.
- The command driver owns `cmd_valid`, safe clock-edge timing, and stable presentation of normal commands until acceptance.
- `PULSE_ONE_CYCLE` is a deliberate unaccepted-command probe; it creates no predictor expectation unless a command handshake occurs.

*Composite Sequences*

- uvm_sequence: cmd_smoke_seq (For testing)
- uvm_sequence: cmd_op (TC-WRAP-ADD-01, TC-XOR-01, TC-SAT-ADD-01, TC-INVALID-OP-01)
- uvm_sequence: cmd_protocol (TC-FULL-01, TC-LATENCY-01, TC-LATENCY-02)
- uvm_sequence: cmd_stress (TC-STRESS-01)
- uvm_sequence: rsp_always_ready (TC-RST-01, TC-RST-02, TC-WRAP-ADD-01, TC-XOR-01, TC-SAT-ADD-01, TC-INVALID-OP-01, TC-LATENCY-01)
- uvm_sequence: rsp_full (TC-FULL-01)
- uvm_sequence: rsp_latency (TC-LATENCY-02)
- uvm_sequence: rsp_stress (TC-STRESS-01)
- uvm_sequence: rst_apply_reset (TC-RST-01, TC-RST-02, All tests where we need to reset for once cycle)

**Sequencer**

- uvm_sequencer: tcs_cmd_sequencer (cmd_req)
- uvm_sequencer: tcs_rsp_sequencer (rsp_req)
- uvm_sequencer: tcs_rst_sequencer (rst_req)
- uvm_sequencer: tcs_virtual_sequencer

**Driver**

- uvm_driver: tcs_cmd_driver (tcs_cmd_sequencer)

  - Applies the command drive policy and waits for acceptance for normal commands; no UVM sequence response is required by default.
- uvm_driver: tcs_rsp_driver (tcs_rsp_sequencer)

  - Response: rdy_valid
- uvm_driver: tcs_rst_driver (tcs_rst_sequencer)

  - Response: n/a

**Monitor**

- uvm_monitor: tcs_cmd_mon (Publishes on cmd acceptance)
- uvm_monitor: tcs_rsp_mon (Publishes on rsp acceptance)
- uvm_monitor: tcs_rst_mon (Publishes on rst)

**Agent**

- uvm_agent: tcs_cmd_agent (tcs_cmd_driver, tcl_cmd_mon, tcs_cmd_sequencer)
- uvm_agent: tcs_rsp_agent (tsc_rsp_driver, tcs_rsp_mon, tcs_rsp_sequencer)
- uvm_agent: tcs_rst_agent (tsc_rst_driver, tcs_rst_mon, tcs_rst_sequencer)

**Coverage Subscriber**

- uvm_subscriber: tcs_coverage

**Predictor**

- uvm_component: tcs_model

**Scoreboard**

- uvm_scoreboard: tcs_scoreboard

**Environment**

- uvm_env: tcs_env

**Test**

- uvm_test: tcs_smoke_test
- uvm_test: tcs_reset_test
- uvm_test: tcs_op_test
- uvm_test: tcs_protocol_test
- uvm_test: tcs_stress_test

**Assertions (Lives in intf)**

**Configuration** 

- config_db supplies each agent’s virtual interface and active/passive mode; tests may set shared timeout and stress-policy defaults.

## Execution plan

| Test              | Purpose                                                    | Seed(s) | Completion evidence                                                                     |
| ----------------- | ---------------------------------------------------------- | ------: | --------------------------------------------------------------------------------------- |
| tcs_reset_test    | Test reset test cases as a baseline                        |    1, 5 | no pre-reset response, correct handshake signals are held low                           |
| tcs_op_test       | Test operations of TCS                                     |    1, 5 | all five legal op × status combinations hit, zero scoreboard errors                    |
| tcs_protocol_test | Test capacity, handshaking, and capacity protocols of TCS. |    1, 5 | full/stall/order/min-latency checks pass, backpressure is sampled                      |
| tcs_stress_test   | Test randomized values for command transactions.           | 2, 5, 8 | every issued accepted command drains correctly, zero errors, required coverage complete |

## Fault evidence

* exact test, seed, and fault command
* first failure ID/message
* expected versus observed evidence
