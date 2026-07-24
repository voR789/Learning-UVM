# UI-10 rubric

Passing requires at least 75/100 and no critical correctness failure.

| Area | Points | Evidence |
|---|---:|---|
| Requirement-derived coverage model | 25 | Four operation bins, two result bins, and full cross match the contract. |
| Analysis sampling implementation | 25 | Subscriber receives and samples all eight observations exactly once. |
| Architecture and reuse | 15 | Publisher is independent of coverage; routing is in `connect_phase`. |
| Coverage closure and fault detection | 15 | 100% required; missing cross combination fails. |
| End-of-test evidence and reproducibility | 10 | Counts, coverage, reports, trace, seed, and exit status agree. |
| Reflection | 10 | Explains observed sampling, crosses, correctness separation, and reuse. |

Critical failures include sampling driver intent, sampling more than once per
observation, accepting incomplete cross coverage, or coupling the publisher
directly to the coverage model.
