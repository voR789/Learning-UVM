# UI-01 Architecture Map

Complete the last two columns in your own words after reading the lesson and
running the example. Do not rewrite FV-G1.

| FV-G1 responsibility | Evidence in FV-G1 | Proposed UVM responsibility | Why this boundary remains useful |
|---|---|---|---|
| Request intent | `req_trans` and scenario tasks | sequence item/sequence | This boundary is useful to abstract because It lets us change which operations and scenarios are requested without changing how the driver translates each request into timed DUT pin activity.|
| Timed pin driving | `driver()` | driver | Abstracting the driver allows us to change the way pins are wiggled (for example adding more pins or removing some), without changing the rest of the environment. |
| Passive observation | `monitor()` | monitor | Allows us to isolate the way we watch pins for different architectures, for example combinational, sequential, etc. Also allows us to adjust for different latencies as well without changing the rest of the environment. |
| Independent prediction | `predictor()` and model queue | predictor | Allows us to swap out models if we want to change our approach or change the way we calculate things (still matching hardware spec), without affecting anything else. |
| Correctness checking | `scoreboard()` | scoreboard | Allows us to change the way we check things without having to change anything else. Ex: tolerance criteria, what counts as a mismatch... |
| Scenario coverage | `fifo_cg` | coverage subscriber | Separates the monitor and coverage information, such that the coverage model can change its parameters without changing the monitor |
| Test orchestration and termination | main process, end markers, `check_done` | uvm_test level, run-phase objection functions | We can control the ending of phases with a central, simple objection system that helps us safely end component phases. |

## Predictions

1. Which mapped role should be the only active writer of DUT request pins?
   - The driver
2. Which mapped role must remain independent of DUT status outputs when deriving expected behavior?
   - The predictor
