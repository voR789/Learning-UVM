# UA-09 rubric

Passing score: 75/100 with no state-coherence or access-path failure.

| Area | Points | Evidence |
|---|---:|---|
| Backdoor synchronization | 30 | A supplied direct backdoor observes the external value, then `predict()` synchronizes desired/mirrored state without frontdoor traffic. |
| Desired-state staging | 20 | `set()` changes desired state without directly changing implementation or mirror state. |
| Frontdoor commit | 25 | `update()` commits the staged value through the supplied frontdoor map. |
| Fault evidence | 15 | Predict-without-observation fails through the synchronization invariant. |
| Reflection | 10 | Learner explains actual, desired, mirrored, frontdoor, backdoor, mirror, predict, set, and update responsibilities. |
