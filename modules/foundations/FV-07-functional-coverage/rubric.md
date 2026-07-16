# FV-07 Rubric

| Area | Points | Evidence |
|---|---:|---|
| Requirement-derived coverage model | 30 | Every required coverpoint and bin has explicit verification intent |
| Cross coverage | 20 | Defined operations are crossed with both zero-result states; invalid operations are excluded intentionally |
| Sampling correctness | 20 | Coverage is sampled once per completed transaction, not arbitrary cycles |
| Coverage analysis and closure | 20 | Initial holes are identified and closed with purposeful minimal stimulus |
| Reflection | 10 | Learner distinguishes occurrence measurement from correctness checking |

Passing requires at least 75 points, 100% of the required reachable bins, and a completed reflection. Coverage percentage alone cannot compensate for an incorrect model.
