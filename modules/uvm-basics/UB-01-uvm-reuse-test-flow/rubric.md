# UB-01 rubric

Passing requires at least 75/100 and no unsafe driver-ownership decision.

| Area | Points |
|---|---:|
| Active/passive ownership decisions | 30 |
| Reuse boundary reasoning | 25 |
| UVM test-flow ownership | 25 |
| Executable observation and reproducibility | 10 |
| Reflection and transfer reasoning | 10 |

Critical failures include assigning two active drivers to one interface,
removing passive observation with the driver, or placing structural construction
under sequence ownership.
