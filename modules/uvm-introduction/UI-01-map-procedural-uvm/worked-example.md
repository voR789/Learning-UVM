# Worked example: registered-command peripheral

This example is deliberately separate from the learner worksheet. Imagine a
small peripheral that accepts a command and produces a registered result one
cycle later.

## Responsibilities

| Verification need | UVM-shaped owner | Reason |
|---|---|---|
| Describe one command | Sequence item | Packages intent without pin timing |
| Choose reset and command order | Sequence | Describes scenario policy |
| Coordinate the next command | Sequencer | Mediates sequence-to-driver item flow |
| Drive command pins around clock edges | Driver | Owns active interface timing |
| Capture request and settled response | Monitor | Publishes what actually happened |
| Calculate the expected registered result | Predictor | Keeps expected behavior independent |
| Compare result and status | Scoreboard | Centralizes correctness decisions |
| Record command/result scenarios | Coverage subscriber | Measures occurrence, not correctness |
| Select configuration and start scenario | Test | Owns top-level intent |
| Contain and connect reusable roles | Environment | Provides stable structure |

## One transaction trace

```text
1. A sequence creates command item opcode=ADD, a=2, b=3.
2. The sequencer offers that item to the driver.
3. The driver drives the command before the active edge.
4. The DUT updates its registered response at the active edge.
5. The monitor samples the settled request and response as one observation.
6. The predictor calculates expected result=5 from the observed request.
7. The scoreboard compares expected result=5 with the observed response.
8. Coverage records that ADD with nonzero operands occurred.
```

Notice that the driver does not decide whether the result is correct, and the
monitor does not predict it. Those separations survived from the procedural
testbench.

## Executable example

The source under `tb/` demonstrates only persistent UVM hierarchy and role
ownership. It intentionally does not implement the entire transaction trace;
later modules introduce connections and transaction-level handshakes one piece
at a time.

Before running, predict which nodes will appear beneath `uvm_test_top.env`.
