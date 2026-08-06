# Scenario specification

The request processor has three modes and two length classes:

- Mode 0 accepts short successful requests and medium requests that complete with an error response. Retry is not used.
- Mode 1 accepts medium successful requests and long requests that first report an error and then retry.
- Mode 2 accepts short and long successful requests. Mode 2 never reports an error and never retries.

The six required scenarios are:

| ID | Mode | Length | Error | Retry | Requirement |
|---:|---:|---|---:|---:|---|
| 0 | 0 | short | 0 | 0 | Basic short success |
| 1 | 0 | medium | 1 | 0 | Mode-0 medium error |
| 2 | 1 | medium | 0 | 0 | Mode-1 medium success |
| 3 | 2 | short | 0 | 0 | Mode-2 short success |
| 4 | 1 | long | 1 | 1 | Mode-1 long retry |
| 5 | 2 | long | 0 | 0 | Mode-2 long success |

All other mode/length/error/retry combinations are outside the accepted protocol. In particular:

- Mode 0 does not accept long requests.
- Mode 1 does not accept short requests.
- Mode 2 never produces error or retry behavior.
- Retry is legal only for the mode-1 long error scenario.

Coverage closure requires observing all six required scenarios. Prohibited combinations must not be stimulated merely to increase a metric.
