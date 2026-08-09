# DV-C1 rubric

Passing requires at least 85/100 and no critical correctness failure.

| Area | Points |
|---|---:|
| Functional checking and meaningful fault detection | 30 |
| Architecture and independent passive evidence | 20 |
| Handshake, latency, backpressure, reset, and drain correctness | 20 |
| Requirement-level coverage and honest disposition | 10 |
| Reproducible regression and debugging evidence | 15 |
| Concise engineering report | 5 |

Critical failures include a checker derived from driver-only intent, loss of
tag/ordering identity, sampling without handshake qualification, unstable or
unbounded termination, a correct-DUT false pass with missing checks, weakening
checks for F1, or coverage claimed from generated rather than observed traffic.
