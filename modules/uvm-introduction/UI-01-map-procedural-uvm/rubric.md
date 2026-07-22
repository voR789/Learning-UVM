# UI-01 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Responsibility mapping | 35 | Every FV-G1 role maps to a plausible UVM responsibility without combining active driving and passive observation |
| Object versus component reasoning | 20 | Sequence items and sequences are distinguished from persistent hierarchy components |
| Transaction-flow explanation | 20 | The map preserves intent, driving, observation, prediction, checking, coverage, and termination order |
| Executable observation | 10 | XSim hierarchy example passes and the learner explains at least one observed parent/child relationship |
| Reuse reasoning | 5 | Boundary explanations connect standard ownership to reuse or debug locality |
| Reflection | 10 | Answers explain what UVM standardizes and what verification reasoning remains project-specific |

Passing requires at least 75 points, a passing runner, and no critical ownership misconception such as making the monitor drive pins or using DUT outputs as the prediction oracle.
