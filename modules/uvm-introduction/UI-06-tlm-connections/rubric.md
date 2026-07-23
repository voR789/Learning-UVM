# UI-06 Rubric

| Area | Points | Evidence |
|---|---:|---|
| FIFO transaction path | 25 | Producer-to-FIFO put and FIFO-to-consumer get paths transfer one correct item |
| Direct implementation path | 20 | Audit put port reaches audit imp and executes sink-owned put task once |
| Endpoint and lifecycle reasoning | 20 | Learner distinguishes port/export/imp and build/connect/run responsibilities |
| Completion and fault detection | 20 | Barrier prevents early pass and misroute cannot complete successfully |
| Diagnostics and reproducibility | 5 | Seed, counts, FIFO use, and explicit result are visible |
| Reflection | 10 | Learner explains decoupling, blocking behavior, and ownership |

Passing requires 75 points, one check at each destination, and a drained FIFO.
