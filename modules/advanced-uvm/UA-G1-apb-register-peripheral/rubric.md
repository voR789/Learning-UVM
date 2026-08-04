# UA-G1 rubric

Passing score: 80/100 with no critical passive-observation, independent-checking,
fault-detection, or termination failure.

| Area | Points | Evidence |
|---|---:|---|
| Passive APB observation | 15 | Exactly one complete transaction is published per completed access, with request and response fields sampled from pins. |
| Independent prediction and checking | 25 | Pre-transfer state predicts errors; accepted writes update an independent model; two result reads are checked without driver or RAL-oracle coupling. |
| RAL response-driven scenario | 20 | Disabled rejection, normal operation, bounded status polling, saturation, and status/data checks execute through the supplied map. |
| Integration architecture and termination | 15 | Monitor fans out to predictor, scoreboard, and coverage; the test waits on a scoreboard drain condition. |
| Functional coverage | 10 | Required addresses, directions, response classes, and result classes are sampled from monitored transfers. |
| Fault and reproducibility evidence | 10 | Seed 1 passes and the same checking contract rejects the faulty result implementation. |
| Plan, evidence summary, and reflection | 5 | Bounded learner-owned artifacts accurately explain the implemented flow and reproduction. |
