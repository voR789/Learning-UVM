# DV-C1 capstone report

Keep this concise and evidence-based:

1. Architecture and the most important ownership decision.

- The architecture uses a triple channel protocol for both the stimulus layer as well as the analysis layer. In the stimulus layer, signals are divided into command, response, and reset input transactions, whilst obseravtions do the same but with outputs included as well. A virtual sequencer drives these three channels into three agents that drive the DUT. On the analysis layer, a predictor samples the accepted commands, and creates expected results - all handshaking logic is abstracted, and delegated to the monitor which only observes accepted commands and responses. The scoreboard checks every fields after all transactions have been sent, using a FIFO to sync transactions due to the nature of the desingn. The coverage group covers all relevant fields, as well as specific behavior flags in our design.
- The most important ownership decision was abstracting the handshaking behavior from the operation of the model, as this simplified our transaction level modeling, while also making it more robust.

2. Exact regression matrix and total/pass/fail.

- All 9 tests passed:

* reset: seeds 1, 5
* operations: seeds 1, 5
* protocol: seeds 1, 5
* stress: seeds 2, 5, 8

3. Coverage achieved plus any requirement-level disposition.

- 100% coverage, all features checked

4. One fault: first decisive signature, root cause, smallest repair or diagnosis,
   and exact reproducing command.

- `UVM_ERROR C:/Learning UVM/modules/internship-readiness/DV-C1-blind-protocol-capstone/tb/dvc1_analysis.sv(240) @ 2255000: uvm_test_top.tcs_env.tcs_scoreboard [DATA_MISMATCH] Expected rsp_data= bf, Actual rsp_data= be, cmd: cmd_tag=0x2 cmd_op=0x1 cmd_a=0x88 cmd_b=37 acc_cycle=8` Root cause is XOR command does not ellicit expected response (`2'b01`) , fix last bit calculation for XOR operation. `.\run.ps1 -Test tcs_stress_test -Seed 1 -Fault F1`

5. Remaining verification risk.

- Model does not exactly model inner latencies of design, and uses standard delay based drains to let responses come out, so that behavior is not fully verified.
