# UI-05 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Reusable environment composition | 30 | One env owns agent, predictor, and scoreboard in both tests |
| Active/passive agent policy | 25 | Monitor always exists; driver exists only in active mode |
| Configuration ownership | 20 | Test selects policy through config; env propagates it before agent build |
| Negative-case detection | 10 | Always-driver fault fails passive topology |
| Diagnostics and reproducibility | 5 | Both test names, seed, topology, mode, and explicit result are visible |
| Reflection | 10 | Learner explains agent/env/test/config boundaries and future connection needs |

Passing requires 75 points, both passing tests, and no passive-mode driver.
