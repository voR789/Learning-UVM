# UI-01 Architecture Map

Complete the last two columns in your own words after reading the lesson and
running the example. Do not rewrite FV-G1.

| FV-G1 responsibility | Evidence in FV-G1 | Proposed UVM responsibility | Why this boundary remains useful |
|---|---|---|---|
| Request intent | `req_trans` and scenario tasks | TODO | TODO |
| Timed pin driving | `driver()` | TODO | TODO |
| Passive observation | `monitor()` | TODO | TODO |
| Independent prediction | `predictor()` and model queue | TODO | TODO |
| Correctness checking | `scoreboard()` | TODO | TODO |
| Scenario coverage | `fifo_cg` | TODO | TODO |
| Test orchestration and termination | main process, end markers, `check_done` | TODO | TODO |

## Predictions

1. Which mapped role should be the only active writer of DUT request pins?
   - TODO
2. Which mapped role must remain independent of DUT status outputs when deriving expected behavior?
   - TODO
