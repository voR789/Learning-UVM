# UI-02 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Policy behavior | 30 | Exact and tolerance policies accept and reject all required observations correctly |
| Polymorphic dispatch | 25 | One unchanged base-handle caller dispatches to both derived overrides without type branching |
| Inheritance and handle reasoning | 20 | The learner explains the base contract, derived object, handle type, and runtime object type |
| Fault detection and diagnostics | 10 | A clear mismatch fails and diagnostics identify policy and values |
| Reproducibility and clarity | 5 | Seed and explicit pass/fail result are reported |
| Reflection | 10 | Answers connect virtual dispatch to verification reuse and identify the non-virtual failure mode |

Passing requires at least 75 points, a passing XSim run, and no critical
misconception such as branching on derived type instead of using virtual
dispatch.
