# FV-G1 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Functional correctness and fault detection | 35 | Independent model checks ordering, data, occupancy, flags, reset, blocked requests, and simultaneous behavior; at least one seeded defect is reproduced and localized |
| Architecture and separation | 20 | Stimulus, driving, passive observation, prediction, checking, and coverage have clear ownership and communicate without corrupting transactions |
| Protocol, timing, reset, and concurrency | 15 | Pre-edge acceptance, post-edge observation, synchronous reset, timeout, and end-of-test behavior are race-safe |
| Assertions and functional coverage | 10 | Useful FIFO invariants are asserted and requirement-derived bins/crosses measure boundary and operation scenarios |
| Reproducibility, diagnostics, and evidence | 10 | Deterministic baseline, recorded seed, useful mismatch context, explicit result markers, and concise evidence summary |
| Explanation and reflection | 10 | Learner explains the architecture, defect evidence, coverage limits, and reusable UVM mapping |

Passing requires at least 80 points, no critical correctness failure, executable fault evidence, and completed learner-owned documentation.
