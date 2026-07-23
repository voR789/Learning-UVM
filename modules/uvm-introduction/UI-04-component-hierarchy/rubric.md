# UI-04 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Component hierarchy | 30 | Required test, container, and leaf instances exist at exact full paths |
| Factory construction and parenting | 25 | Both children use type_id::create in build_phase with correct names and `this` parent |
| Lifecycle reasoning | 20 | Learner explains run_test selection, top-down build, run_phase, and objections |
| Negative-case detection | 10 | Wrong-parent hierarchy fails for the intended path mismatch |
| Reproducibility and diagnostics | 5 | Seed, topology, full paths, and explicit result are reported |
| Reflection | 10 | Answers distinguish type, handle, instance name, parent, and full path |

Passing requires at least 75 points, a passing XSim run, and no critical
misconception such as constructing persistent children in run_phase or passing
the wrong parent.
