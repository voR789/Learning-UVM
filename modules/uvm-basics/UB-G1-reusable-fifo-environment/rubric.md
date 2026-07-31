# UB-G1 rubric

| Area | Points |
|---|---:|
| Known-good behavior and faulty-DUT rejection | 30 |
| Independent passive FIFO prediction and checking | 20 |
| Request/response timing and adaptive bounded sequence | 20 |
| Reusable agent architecture and ownership boundaries | 10 |
| Functional coverage and deterministic completion | 10 |
| Evidence summary and reflection | 10 |

Passing requires at least 80 points, a passing known-good run, and rejection of
the early-full DUT specifically through `UBG1_MISMATCH`.
