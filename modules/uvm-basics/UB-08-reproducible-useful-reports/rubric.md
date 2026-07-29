# UB-08 Rubric

| Area | Points |
|---|---:|
| Every observation is accounted for | 20 |
| Mismatch report includes seed and transaction context | 30 |
| First failure and final counts are preserved | 20 |
| Report phase emits a useful clean and faulty summary | 15 |
| Transaction-recording purpose and reproducibility are explained | 15 |

Passing requires at least 75 points, a clean-run pass, and rejection of the
injected fault specifically through `UB08_MISMATCH`.
