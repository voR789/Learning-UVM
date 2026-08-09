# DV-03 coverage disposition

Keep this compact. The decisions—not prose volume—are the evidence.

| Candidate hole             | Reachable? | Specification evidence                                                                                           | Closure action            | Observed proof                      |
| -------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------- | ----------------------------------- |
| Mode 1, long, error, retry | Yes        | "- Mode 1 accepts medium successful requests and long requests that first report an error and then retry.<br />" | -  Add targeted stimulus | DV03_OBS plus observed_required=6/6 |
| Mode 2, long, success      | Yes        | "Mode 2 accepts short and long successful requests"                                                              | - Add targeted stimulus   | DV03_OBS plus observed_required=6/6 |
| Mode 2, any error          | No         | "Mode 2 never reports an error and never retries."                                                               | - N/A                     |                                     |
| Mode 0, long               | No         | "- Mode 0 does not accept long requests."                                                                        | - N/A                     |                                     |

## One-sentence integrity check

Why would excluding either required reachable scenario be metric gaming?

- It would be gaming the system because they are real situations that could happen, and leaving them out to reach full coverage could cause bugs later on.
