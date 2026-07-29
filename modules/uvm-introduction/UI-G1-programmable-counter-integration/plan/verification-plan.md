# UI-G1 verification plan

Complete before implementation.

| Requirement | Stimulus | Authoritative observation | Prediction/check | Coverage evidence | Failure symptom |
|---|---|---|---|---|---|
| Reset produces zero | Operations 0-1: LOAD `8'hFF`, then assert reset with `cmd_valid=0` | During each requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | LOAD produces `8'hFF`; RESET then produces `8'h00` | `cp_reset.asserted` is hit | Count retains the previously loaded sentinel after reset. |
| LOAD installs value | Operations 0, 2, 4, 6, and 11 issue LOAD with `8'hFF`, `8'h05`, `8'h05`, `8'hFF`, and `8'hAA` | During each requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | Each count equals that operation's `load_value` | `cx_cmd_count.load_max` and `cx_cmd_count.load_middle` are hit | Count differs from the requested load value. |
| INC increments | Operations 2-3: LOAD `8'h05`, then INC | During each requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | Count changes from `8'h05` to `8'h06` | `cx_cmd_count.inc_middle` is hit | Count does not equal `8'h06` after INC. |
| DEC decrements | Operations 4-5: LOAD `8'h05`, then DEC | During each requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | Count changes from `8'h05` to `8'h04` | `cx_cmd_count.dec_middle` is hit | Count does not equal `8'h04` after DEC. |
| CLEAR produces zero | Operations 6-8: LOAD `8'hFF`, CLEAR, then HOLD | During each requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | CLEAR produces `8'h00`; HOLD retains `8'h00` | `cx_cmd_count.clear_zero` and `cx_valid_count.hold_zero` are hit | CLEAR does not produce zero, or HOLD does not retain it. |
| INC wraps 255 to 0 | Operation 10 issues INC after operation 9 wrapped the count to `8'hFF` | During the requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | Count wraps from `8'hFF` to `8'h00` | `cx_cmd_count.inc_zero` is hit | Count does not wrap to zero. |
| DEC wraps 0 to 255 | Operation 9 issues DEC after CLEAR and HOLD established zero | During the requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | Count wraps from `8'h00` to `8'hFF` | `cx_cmd_count.dec_max` is hit | Count does not wrap to `8'hFF`. |
| `cmd_valid=0` retains value | Operations 8 and 12 issue HOLD after CLEAR-to-zero and LOAD `8'hAA`, respectively | During each requested clock edge: {`rst_n`, `cmd_valid`, `cmd`, `load_value`}; after sequential settling: {`count`} | HOLD retains `8'h00` and later `8'hAA` | `cx_valid_count.hold_zero` and `cx_valid_count.hold_middle` are hit | Count changes while `cmd_valid=0`. |

## Completion invariant

Explain why all of these must agree before PASS:

```text
driver completions == monitor publications == scoreboard checks == coverage samples == 13
```

All of the variables listed must agree because these indicate the amount of times each component of the UVM hierarchy has run, and if they are not equal, that indicates that either the testing process is not finished (some components still need to drain), or that there is a leak somewhere, and the test is losing/creating transactions.
