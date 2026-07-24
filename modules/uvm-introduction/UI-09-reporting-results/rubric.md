# UI-09 rubric

Passing requires at least 75/100 and no critical correctness failure.

| Area | Points | Evidence |
|---|---:|---|
| Report classification and fault detection | 30 | Exact, recoverable, and incorrect results receive correct severities and counts. |
| End-of-test verdict | 25 | Local work and global report counts jointly control PASS. |
| Reporting architecture | 15 | Stable IDs, useful diagnostics, and component-local reporting policy. |
| Verbosity control | 10 | Low info is visible, high detail filtered, severities unaffected. |
| Reproducibility and diagnostics | 10 | Deterministic seed, exact trace, nonzero failure on UVM errors/fatals. |
| Reflection | 10 | Explains severity, verbosity, IDs, count evidence, and termination. |

Critical failures include printing PASS despite UVM errors, downgrading a true
mismatch, clearing report counts, or bypassing UVM reporting with `$display`.
