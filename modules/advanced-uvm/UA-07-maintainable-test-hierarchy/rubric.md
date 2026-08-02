# UA-07 rubric

Passing score: 75/100 with no critical lifecycle or false-pass failure.

| Area | Points | Evidence |
|---|---:|---|
| Shared lifecycle contract | 30 | The base test owns selection, null rejection, objection scope, execution, and completion. |
| Reusable hierarchy boundary | 20 | Both derived tests inherit `run_phase()` and vary only scenario selection. |
| Accounting and false-pass prevention | 20 | Nonzero verified work agrees with driver accounting before completion is recorded. |
| Regression and reproduction | 15 | The documented test/seed matrix passes and one row can be rerun directly. |
| Fault evidence | 10 | The bypass fixture fails through `UA07_CONTRACT`. |
| Reflection | 5 | The learner explains ownership, termination, selection, and reproduction concisely. |
