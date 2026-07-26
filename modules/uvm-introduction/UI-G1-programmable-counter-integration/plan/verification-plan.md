# UI-G1 verification plan

Complete before implementation.

| Requirement | Stimulus | Authoritative observation | Prediction/check | Coverage evidence | Failure symptom |
|---|---|---|---|---|---|
| Reset produces zero | Setup: start with reset state. Then load `8'hFF` as a sentienl value. Stimulus: `rst_n` =  `1'b0`, `cmd_valid` = `1'b0`, `cmd` = `2'b00`, `load_value` = `8'h0` | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | `count` = `8'h0` | Checks if reset occured | Count retains sentinel value after reset. |
| LOAD installs value | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` =  | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |
| INC increments | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` = | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |
| DEC decrements | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` =  | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |
| CLEAR produces zero | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` =  | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |
| INC wraps 255 to 0 | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` =  | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |
| DEC wraps 0 to 255 | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` =  | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |
| `cmd_valid=0` retains value | Setup: start with reset state. Stimulus: `rst_n` =  , `cmd_valid` = , `cmd` = , `load_value` =  | During the clock edge: {`rst_n`,`cmd_valid`, `cmd`, `load_value`}, after sequential settling, {`count`} | TODO | TODO | TODO |

## Completion invariant

Explain why all of these must agree before PASS:

```text
driver completions == monitor publications == scoreboard checks == coverage samples == 9
```

All of the variables listed must agree because these indicate the amount of times each component of the UVM hierarchy has run, and if they are not equal, that indicates that either the testing process is not finished (some components still need to drain), or that there is a leak somewhere, and the test is losing/creating transactions.
